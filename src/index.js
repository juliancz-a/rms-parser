// You can try using the parser using this basic template.
// Edit "test.rms" with any .rms or similar syntax file. 
// Check the result through "output.json" file.

const parser = require('./RMSgrammar.js');
const fs = require('fs');

const content = fs.readFileSync("test.rms", "utf8");

try {
    const result = parser.parse(content);
    fs.writeFileSync("output.json", JSON.stringify(result, null, 2));
    console.log("File output.json saved.");

} catch (error) {
    console.error("Parse error: ", error.message);
}