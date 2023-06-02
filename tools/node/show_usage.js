// Make sure we got a filename on the command line.
if (process.argv.length < 3) {
    console.log('Usage: node ' + process.argv[1] + ' FILENAME');
    process.exit(1);
}

// Read the file and print its contents.
var fs = require('fs')
    , filename = process.argv[2];
var data = fs.readFileSync(filename, 'utf8');

var obj = Object.fromEntries(data.split('\n').splice(2).map(line => line.split(':').map(x => x.trim())));

var segemnt_sizes = [
    ["ZEROPAGE", 0x0100, "Zeropage"],
    ["STACK", 0x0100 - 64, "RAM at Stack"],
    ["RAM", 0x0500, "RAM"],
    ["WRAM0", 0x2000, "Map"],
    [],
    ["BANK10", 0x2000, "General Data"],
    ["BANK11", 0x2000, "Intro/End Code"],
    ["BANK13", 0x2000, "Game Code"],
    ["BANK1D", 0x2000, "PPU Transfer Routines"],
    ["BANK1E", 0x3E00, "Main Code"],
    ["BANK1F", 0x01FA, "System Code"],
    [],
    ["ZP0", 0x0100-0x24, "Zeropage 0"],
    ["ZP1", 0x0100-0x24, "Zeropage 1"],
    ["WRAM1", 0x2000, ""],
    ["BANK14", 0x2000, "Credits"],
    ["BANK15", 0x2000, "Settings"],
    ["BANK16", 0x2000, "Help"],
    [],
    ["BANK12", 0x2000, "Unused"],
    ["BANK17", 0x2000, "Unused"],
    ["BANK18", 0x2000, "Unused"],
    ["BANK19", 0x2000, "Music Code + Data"],
    ["BANK1A", 0x2000, "Music Data"],
    ["BANK1B", 0x2000, "Music Data"],
    ["BANK1C", 0x2000, "Music Data"],
    // ["OAM",       0x0100, ""],
    // ["BANK00",    0x2000, "Map 1"],
    // ["BANK01",    0x2000, "Map 2"],
    // ["BANK02",    0x2000, "Map 3"],
    // ["BANK03",    0x2000, "Map 4"],
    // ["BANK04",    0x2000, "Map 5"],
    // ["BANK05",    0x2000, "Map 6"],
    // ["BANK06",    0x2000, "Map 7"],
    // ["BANK07",    0x2000, "Map 8"],
    // ["BANK08",    0x2000, "Map 9"],
    // ["BANK09",    0x2000, "Map 10"],
    // ["BANK0A",    0x2000, "Map 11"],
    // ["BANK0B",    0x2000, "Map 12"],
    // ["BANK0C",    0x2000, "Map 13"],
    // ["BANK0D",    0x2000, "Map 14"],
    // ["BANK0E",    0x2000, "Map 15"],
    // ["BANK0F",    0x2000, "Map 16"],
    // ["TILES",     0x20000, ""],
];

const format = (n, r, l, f) => n.toString(r).toUpperCase().padStart(l, f);
const formatBar = (p,n) => {
    const progStep = ' ⡀⡄⡆⡇⣇⣧⣷⣿'.split("");
    const a = (n * p) >> 0;
    const b = (((n * p) % 1) * progStep.length) >> 0;
    if (n==a)
        return "|"+progStep.slice(-1)[0].repeat(a)+"|";
    else
        return "|"+progStep.slice(-1)[0].repeat(a) + progStep[b] + " ".repeat(n-a-1)+"|";
}
for (seg_info of segemnt_sizes) {
    if (seg_info.length === 0) {
        console.log("")
        continue
    }
    var name = seg_info[0];
    var size = seg_info[1];
    var comment = seg_info[2];
    var usage = parseInt(obj[name]) || 0;
    // if (usage == 0) continue;
    console.log(
        "  " +
        (name + ":").padEnd(9) +
        "  " +
        format(usage, 10, 5, " ") + 
        " / " + 
        format(size, 10, 5, " ") + 
        " (" + 
        format(size, 16, 4, "0") + 
        ")" + 
        "    " +
        formatBar(usage / size, 10) +
        " " +
        ((usage / size * 100).toFixed(2) + "%").padStart(7) + 
        "    " +
        format(size - usage, 10, 5, " ") + " bytes left" + 
        "    " +
        comment +
        ""
    )
}