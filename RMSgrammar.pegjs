{
    function buildList(head, tail, index) {
        return [head].concat(extractList(tail, index));
    }

    function extractList(list, index) {
        return list.map(function(element) { return element[index]; });
    }

    function optionalList(value) {
        return value !== null ? value : [];
    }

    function mapElseIfs(elseIfs) {
        return elseIfs.map((elseIf) => {
            return {
                condition: elseIf[1].condition,
                statements: elseIf[1].statements
            };
        });
    }
}

Start
    = _ program:Program _ { return program; }

Program
    = body:SourceElements? {
        return {
            type: "RMS AST",
            body: optionalList(body)
        };
    }

SourceElements
    = head:SourceElement tail:(__ SourceElement)* {
        return buildList(head, tail, 1);
    }

SourceElement
    = Statement
    / Section
    / Constant
    / Variable
    / Import

Statement
    = stmt:(ConditionalStatement / CommandStatement / RandomStatement / AttributeStatement / GenericAttribute ) { return stmt; }

Variable
    = VariableToken __ value:Argument {
        return { type: "variable", value };
    }

Constant
    = ConstantToken __ value:Attribute {
        return { type: "constant", value: value.name, args: value.args };
    }

ConditionalStatement
    =   "if" __ condition:Identifier 
        then:(__ SourceElements)?
        elseIfs:(__ ElseIfBlock)* 
        alternate:(__ ElseBlock)?
        __ "endif" {
            return {
                type: "conditional_block",
                condition,
                then: { statements: then ? optionalList(then[1]) : [] },
                elseIfs: mapElseIfs(elseIfs),
                alternate: alternate ? { statements: alternate[1] } : null
            };
    }

ElseIfBlock
    = "elseif" __ condition:Identifier __ alt:(SourceElements)? {
        return {
            condition: condition,
            statements: optionalList(alt)
        };
    }

ElseBlock
    =  "else" __ alt:(SourceElements)? { return optionalList(alt); }

CommandStatement
    = cmd:CommandName args:(__ arg:Argument { return arg; })? __
        "{" _ body:SourceElements? _ "}" {
            return {
                type: "command_block",
                name: cmd,
                args: args,
                body: optionalList(body)
            };
        }

RandomStatement
    = "start_random" __
        statements:RandomBlock+
        "end_random" {
            return {
                type: "random_block",
                statements : statements
            };
        }

RandomBlock
    = RandomToken __ chance:Number variable:(__ v:Variable {return v;})? __ {
        return {
            percent_chance : chance,
            variable: variable ? variable.value : null
            }
        }

Argument
    = Number / Identifier

GenericAttribute
    = name:Identifier args:(__ arg:Argument { return arg; })* {
        return {
            type: "attribute",
            name: name,
            args: args
        };
    }

ImportPath
    = path_str:([a-zA-Z0-9_]+ "." "inc") {
        return text()
    }

Number
    = chars:("-"? [0-9]+ ("." [0-9]+)?) {
        return parseFloat(text());
    }

Identifier
    = !Keyword head:[A-Za-z_] tail:[A-Za-z0-9_-]* {
        return head + tail.join('');
    }

Keyword
    = IfToken
    / ElseToken
    / ElseIfToken
    / EndIfToken
    / StartRandomToken
    / EndRandomToken
    / VariableToken
    / ConstantToken
    / CommandName
    / RandomToken
    / AttributeStatement
    / IncludeToken
    / ImportPath


//Tokens
IfToken
    = "if"
ElseToken
    = "else"
ElseIfToken
    = "elseif"
EndIfToken
    = "endif"

StartRandomToken
    = "start_random"
EndRandomToken
    = "end_random"
RandomToken
    = "percent_chance"

VariableToken
    = "#define"
ConstantToken
    = "#const"
IncludeToken
    = "#include_drs" 

AttributeStatement
	= name:Attribute args:(__ arg:Argument { return arg; })* {
        return {
            attribute: name,
            args: args
        };
    }

Attribute
    = ElevationAttribute

ElevationAttribute
    =   "base_terrain"
    /   "base_layer"
    /   "number_of_tiles"
    /   "number_of_clumps"
    /   "set_scale_by_size"
    /   "set_scale_by_groups"
    /   "spacing"
    /   "enable_balanced_elevation"

CommandName
    = "create_object"
    / "create_terrain"
    / "create_area"
    / "create_land"
    / "create_cliff"
    / "create_connection"
    / "create_player_lands"
    / "create_elevation"

Section
    = Sections {return { type: "section", name: text() }; }

Sections
    =   '<PLAYER_SETUP>'
    /   '<LAND_GENERATION>'
    /   '<ELEVATION_GENERATION>'
    /   '<CLIFF_GENERATION>'
    /   '<TERRAIN_GENERATION>'
    /   '<CONNECTION_GENERATION>'
    /   '<OBJECTS_GENERATION>'

Import
    = IncludeToken __ path:ImportPath {
        return { type: "import", path };
    }
    
Comment
	= "/*" (!("*/") .)* "*/" 
_
    = ( [ \t\n\r] / Comment)*
__
    = ( [ \t\n\r] / Comment)+