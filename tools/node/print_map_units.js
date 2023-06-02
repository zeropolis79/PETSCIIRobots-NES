// Make sure we got a filename on the command line.
if (process.argv.length < 3) {
    console.log('Usage: node ' + process.argv[1] + ' FILENAME');
    process.exit(1);
}

// Read the file and print its contents.
const fs = require('fs')
    , filename = process.argv[2];


for (const f of [..."abcdefghikj"]) {
    exec(filename+"/level-"+f+".unit");
}


function exec(filename) {
    console.log("open " + filename);
    const data = fs.readFileSync(filename);
    const unit = (i) => ({
        t: data[64*0 + i],
        x: data[64*1 + i],
        y: data[64*2 + i],
        a: data[64*3 + i],
        b: data[64*4 + i],
        c: data[64*5 + i],
        d: data[64*6 + i],
        h: data[64*7 + i],
    });

    const str = (x) => x.toString().padStart(3, ' ');
    const unit_unused = [6,8,11,12,13,14,15,20,21,23];

    for (let i=0; i<64; i++) {
        const u = unit(i);
        const {t, x, y, a, b, c, d, h} = u;
        if (unit_unused.includes(t))
            console.log(
                ` ${str(i)}  `+
                `TYPE: ${str(t)}    `+
                `COORD: ${str(x)}, ${str(y)}    `+
                `PARAM: ${str(a)}, ${str(b)}, ${str(c)}, ${str(d)}    `+
                `HEALTH: ${str(h)}    `+
                data2hidden(u)
            );
    }

    // return

    console.log("Player & Robots");
    for (let i=0; i<28; i++) {
        const u = unit(i);
        const {t, x, y, a, b, c, d, h} = u;
        console.log(
            ` ${str(i)}  `+
            `TYPE: ${str(t)}    `+
            `COORD: ${str(x)}, ${str(y)}    `+
            `PARAM: ${str(a)}, ${str(b)}, ${str(c)}, ${str(d)}    `+
            `HEALTH: ${str(h)}    `+
            data2hidden(u)
        );
    }


    console.log("Weapon Fire");
    for (let i=28; i<32; i++) {
        const u = unit(i);
        const {t, x, y, a, b, c, d, h} = u;
        console.log(
            ` ${str(i)}  `+
            `TYPE: ${str(t)}    `+
            `COORD: ${str(x)}, ${str(y)}    `+
            `PARAM: ${str(a)}, ${str(b)}, ${str(c)}, ${str(d)}    `+
            data2hidden(u)
        );
    }

    console.log("Doors & others");
    for (let i=32; i<48; i++) {
        const u = unit(i);
        const {t, x, y, a, b, c, d, h} = u;
        console.log(
            ` ${str(i)}  `+
            `TYPE: ${str(t)}    `+
            `COORD: ${str(x)}, ${str(y)}    `+
            `PARAM: ${str(a)}, ${str(b)}, ${str(c)}, ${str(d)}    `+
            data2hidden(u)
        );
    }

    console.log("Hidden Items");
    for (let i=48; i<64; i++) {
        const u = unit(i);
        const {t, x, y, a, b, c, d, h} = u;
        console.log(
            ` ${str(i)}  `+
            `TYPE: ${str(t)}    `+
            `COORD: ${str(x)}, ${str(y)}    `+
            `PARAM: ${str(a)}, ${str(b)}, ${str(c)}, ${str(d)}    `+
            data2hidden(u)
        );
    }
}


// NOTES ABOUT UNIT TYPES
// ----------------------
// 000=no unit              
// 001=player unit                  
// 002=hoverbot lr                         
// 003=hoverbot ur                  
// 004=hoverbot attack         
// 005=hoverbot water        
// 006=time bomb                    
// 007=transporter                  
// 008=robot dead                        
// 009=evilbot                      
// 010=door                         
// 011=small explosion              
// 012=pistol fire up               
// 013=pistol fire down             
// 014=pistol fire left             
// 015=pistol fire right            
// 016=trash compactor              
// 017=rollerbot ud                           
// 018=rollerbot lr                          
// 019=elevator                             
// 020=magnet                             
// 021=robot magnetized                             
// 022=water raft lr                             
// 023=transporter dem                             

function data2type(unit) {
    switch (unit.t) {
        case   0: return "no unit          ";
        case   1: return "player unit      ";
        case   2: return "hoverbot lr      ";
        case   3: return "hoverbot ur      ";
        case   4: return "hoverbot attack  ";
        case   5: return "hoverbot water   ";
        case   6: return "time bomb        ";
        case   7: return "transporter      ";
        case   8: return "robot dead       ";
        case   9: return "evilbot          ";
        case  10: return "door             ";
        case  11: return "small explosion  ";
        case  12: return "pistol fire up   ";
        case  13: return "pistol fire down ";
        case  14: return "pistol fire left ";
        case  15: return "pistol fire right";
        case  16: return "trash compactor  ";
        case  17: return "rollerbot ud     ";
        case  18: return "rollerbot lr     ";
        case  19: return "elevator         ";
        case  20: return "magnet           ";
        case  21: return "robot magnetized ";
        case  22: return "water raft lr    ";
        case  23: return "transporter dem  ";
        case 128: return "key              ";
        case 129: return "bomb             ";
        case 130: return "emp              ";
        case 131: return "pistol           ";
        case 132: return "plasma           ";
        case 133: return "medkit           ";
        case 134: return "magnet           ";
        default : return "?????????????????";
    }
}

// NOTES ABOUT DOORS.
// -------------------
// A-0=horitzonal 1=vertical
// B-0=opening-A 1=opening-B 2=OPEN / 3=closing-A 4=closing-B 5-CLOSED
// C-0=unlocked / 1=locked spade 2=locked heart 3=locked star
// D-0=automatic / 0=manual

// HIDDEN OBJECTS
// --------------
// UNIT_TYPE:128=key UNIT_A: 0=SPADE 1=HEART 2=STAR
// UNIT_TYPE:129=time bomb
// UNIT_TYPE:130=EMP
// UNIT_TYPE:131=pistol
// UNIT_TYPE:132=charged plasma gun
// UNIT_TYPE:133=medkit
// UNIT_TYPE:134=magnet

function data2hidden(unit) {
    switch (unit.t) {
        // case   5: return JSON.stringify({type: "hoverbot water   ",      loc: [unit.x, unit.y], param: [unit.a, unit.b, unit.c, unit.d]});
        // case   6: return JSON.stringify({type: "time bomb        ",      loc: [unit.x, unit.y], param: [unit.a, unit.b, unit.c, unit.d]});
        // case   8: return JSON.stringify({type: "robot dead       ",      loc: [unit.x, unit.y], param: [unit.a, unit.b, unit.c, unit.d]});
        // case  11: return JSON.stringify({type: "small explosion  ",      loc: [unit.x, unit.y], param: [unit.a, unit.b, unit.c, unit.d]});
        // case  12: return JSON.stringify({type: "pistol fire up   ",      loc: [unit.x, unit.y], param: [unit.a, unit.b, unit.c, unit.d]});
        // case  13: return JSON.stringify({type: "pistol fire down ",      loc: [unit.x, unit.y], param: [unit.a, unit.b, unit.c, unit.d]});
        // case  14: return JSON.stringify({type: "pistol fire left ",      loc: [unit.x, unit.y], param: [unit.a, unit.b, unit.c, unit.d]});
        // case  15: return JSON.stringify({type: "pistol fire right",      loc: [unit.x, unit.y], param: [unit.a, unit.b, unit.c, unit.d]});
        // case  20: return JSON.stringify({type: "magnet           ",      loc: [unit.x, unit.y], param: [unit.a, unit.b, unit.c, unit.d]});
        // case  21: return JSON.stringify({type: "robot magnetized ",      loc: [unit.x, unit.y], param: [unit.a, unit.b, unit.c, unit.d]});
        // case  23: return JSON.stringify({type: "transporter dem  ",      loc: [unit.x, unit.y], param: [unit.a, unit.b, unit.c, unit.d]});

        case   0: return JSON.stringify({type: "NO UNIT"});
        case   1: return JSON.stringify({type: "PLAYER",          loc: [unit.x, unit.y], health: unit.h});
        case   2: return JSON.stringify({type: "HOVERBOT-H",      loc: [unit.x, unit.y], health: unit.h});
        case   3: return JSON.stringify({type: "HOVERBOT-V",      loc: [unit.x, unit.y], health: unit.h});
        case   4: return JSON.stringify({type: "HOVERBOT-ATT",    loc: [unit.x, unit.y], health: unit.h});
        case  17: return JSON.stringify({type: "ROLLERBOT-V",     loc: [unit.x, unit.y], health: unit.h});
        case  18: return JSON.stringify({type: "ROLLERBOT-H",     loc: [unit.x, unit.y], health: unit.h});
        case   9: return JSON.stringify({type: "EVILBOT",         loc: [unit.x, unit.y], health: unit.h});
        case  10: return JSON.stringify({type: "DOOR",            loc: [unit.x, unit.y], dir:["horizonal", "vertical"][unit.a], state: ["opening-A","opening-B","OPEN","closing-A","closing-B","CLOSED"][unit.b], lock: ["unlocked","spade","heart","star"][unit.c]});
        case  19: return JSON.stringify({type: "ELEVATOR",        loc: [unit.x, unit.y], state: ["opening-A","opening-B","OPEN","closing-A","closing-B","CLOSED"][unit.b],currentFloor:unit.c,maxFloor:unit.d});
        case   7: return JSON.stringify({type: "TRANSPORTER",     loc: [unit.x, unit.y], active: ["always", "all_robot_dead"][unit.a],mode:["level_complete","send_to"][unit.b],coord:[unit.c,unit.d]});
        case  22: return JSON.stringify({type: "WATER RAFT",      loc: [unit.x, unit.y], dir:["left","right"][unit.a], compareLeft: unit.b, compareRight:unit.c});
        case  16: return JSON.stringify({type: "TRASH COMPACTOR", loc: [unit.x, unit.y]});
        case 128: return JSON.stringify({type: "KEY",             loc: [unit.x, unit.y], size: [unit.c, unit.d], extra: ["spade", "heart", "star"][unit.a]});
        case 129: return JSON.stringify({type: "BOMB",            loc: [unit.x, unit.y], size: [unit.c, unit.d], amount: unit.a});
        case 130: return JSON.stringify({type: "EMP",             loc: [unit.x, unit.y], size: [unit.c, unit.d], amount: unit.a});
        case 131: return JSON.stringify({type: "PISTOL",          loc: [unit.x, unit.y], size: [unit.c, unit.d], amount: unit.a});
        case 132: return JSON.stringify({type: "PLASMA",          loc: [unit.x, unit.y], size: [unit.c, unit.d], amount: unit.a});
        case 133: return JSON.stringify({type: "MEDKIT",          loc: [unit.x, unit.y], size: [unit.c, unit.d], amount: unit.a});
        case 134: return JSON.stringify({type: "MAGNET",          loc: [unit.x, unit.y], size: [unit.c, unit.d], amount: unit.a});
        default:  return JSON.stringify({type: `???`,             ...unit});
    }
}

// NOTES ABOUT TRANSPORTER
// ----------------------
// UNIT_A:	0=always active	1=only active when all robots are dead
// UNIT_B:	0=completes level 1=send to coordinates
// UNIT_C:	X-coordinate
// UNIT_D:	Y-coordinate
