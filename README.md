# Attack of the Petscii Robots (NES)

## How to build

[MSYS2](https://www.msys2.org/) was used to build the ROM on Windows.
Install `make` with
```bash
  pacman -S make
```
and then call
```bash
  # ROM for NES emulator
  make 
  
  # PRG and CHR ROM for a cartridge
  make rom-bin
```

Tools used to process the resources of the game are prebuild for Windows.  
The source code is provided but needs adjustments if you want to run it on an other system.

## Resources

  - `level`: RAW level data from the C64
  - `metatileset`: RAW metatileset data from the C64 modified for the NES
  - `music`:
    - `*.fms`: FamiStudio track files
    - `*.asm`: Exported by FamiStudio and modified to fit into the ROM
  - `screen`: Nametable screens, can be edited with [Tiled](https://www.mapeditor.org/)
  - `tileset`: can be edited as a normal PNG (has to be 256x256 and use only 4 shades of grey)
