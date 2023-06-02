// Make sure we got a filename on the command line.
if (process.argv.length < 3) {
    console.log('Usage: node ' + process.argv[1] + ' metatileset.gfx');
    process.exit(1);
}

// Read the file and print its contents.
const fs = require('fs')
    , filename = process.argv[2];


const toHex = (v) => v.toString(16).toUpperCase().padStart(2, '0');
const toBin = (v) => v.toString( 2).toUpperCase().padStart(8, '0');


const isWalkable  = v => (v & 0x01) != 0;
const isHoverable = v => (v & 0x02) != 0;
const isCanMove   = v => (v & 0x04) != 0;
const isDestroy   = v => (v & 0x08) != 0;
const isSeeTrough = v => (v & 0x10) != 0;
const isMoveInto  = v => (v & 0x20) != 0;
const isSearch    = v => (v & 0x40) != 0;
const isUnused    = v => (v & 0x80) != 0;

exec(filename);
    
function exec(filename) {
    console.log("open " + filename);
    const data = fs.readFileSync(filename);

    printDestruct(data);
    printMask(data,-1);
    printMask(data, 0);
    
    // console.log("walk (01)");
    // printMask(data, 0x01);
    // console.log("hover (02)");
    // printMask(data, 0x02);
    // console.log("moveable (04)");
    // printMask(data, 0x04);
    // console.log("destroyable (08)");
    // printMask(data, 0x08);
    // console.log("see through (10)");
    // printMask(data, 0x10);
    // console.log("move onto (20)");
    // printMask(data, 0x20);
    // console.log("searchable (40)");
    // printMask(data, 0x40);
}



function printMask(data, mask = 0xFF) {
    let res = '';
    for (let i=0; i<16; i++) {
        let s = '';
        for (let j=0; j<16;j++) {
            const v = data[256+i*16+j];
            const vm = v & mask;
            
            if (mask == -1) {
                s += toHex(v) + ' ';
            }
            else if (mask == 0x00) {
                if (v == 0xFF) {
                    s += '   ';
                } else if (!isWalkable(v) && isMoveInto(v)) {
                    s += '?? ';
                } else if (v == 0x00 || isSearch(v) || isSeeTrough(v)) {
                    s += toHex(v) + ' ';
                } else {
                    s += '-- ';
                }
            } else {
                if (v == 0xFF) {
                    s += '[] ';
                } else if (vm == 0x00) {
                    s += '-- ';
                } else {
                    s += toHex(vm) + ' ';
                }
            }
        }
        res += `${toHex(i*16)}: ${s}\n`;
    }
    console.log(res);
}



function printDestruct(data) {
    let res = '';
    for (let i=0; i<16; i++) {
        let s = '';
        for (let j=0; j<16;j++) {
            s += '0x'+toHex(data[i*16+j]) + ', ';
        }
        res += `${toHex(i*16)}: ${s}\n`;
    }
    console.log(res);
}