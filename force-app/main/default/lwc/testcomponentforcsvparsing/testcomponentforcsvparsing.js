import { LightningElement } from 'lwc';
import PARSER from '@salesforce/resourceUrl/papaparser';
import { loadScript } from 'lightning/platformResourceLoader';
export default class Testcomponentforcsvparsing extends LightningElement {
parserInitialized = false
renderedCallback() {
if (!this.parserInitialized) {
Promise.all([
loadScript(this,PARSER),
])
.then(() => {
console.log("Papa Parser loaded successfully.");
})
.catch(error => {
console.log("Failed to load JS lib:", error);
});
}
}

handleInputChange(event){
    if(event.target.files.length > 0){
    const file = event.target.files[0];
    Papa.parse(file, {
    quoteChar: '”',
    header: 'true',
    complete: (results) => {
    console.log(results.data);
    },
    error: (error) => {
    console.error(error);
    }
    });
    }
    }

}