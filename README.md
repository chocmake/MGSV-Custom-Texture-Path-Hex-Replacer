# MGSV Custom Texture Path Hex Replacer

Simplifies custom FTEX texture path hex replacement in FMDL/FV2 files, the manual process of which was outlined originally on BobDoleOwndU's [wiki page](http://bobdoleowndu.github.io/mgsv/documentation/customtexturenames.html).

### Requirements

- [GzsTool (BobDoleOwndU version)](https://github.com/BobDoleOwndU/GzsTool/releases)
- [XVI32 hex editor](http://www.chmaas.handshake.de/delphi/freeware/xvi32/xvi32.htm)
- [XVIscript script](https://raw.githubusercontent.com/chocmake/MGSV-Custom-Texture-Path-Hex-Replacer/master/HexRepl.xsc) from this repository

![Screenshot](https://raw.githubusercontent.com/chocmake/MGSV-Custom-Texture-Path-Hex-Replacer/master/Screenshot.png)

### Installation

1. Install the required programs.
2. Download the zip from the [Releases tab](github.com/chocmake/MGSV-Custom-Texture-Path-Hex-Replacer/releases/).
3. Launch `MGSV-Custom-Texture-Path-Hex-Replacer.bat`.
4. Drag and drop the installed programs and the included script on the window as prompted to save the paths to the script.

### Usage

Open the script and follow the prompts. Drag and drop the original FTEX texture file, followed by the modded FTEX file with the custom filename (or directory path, or both), then finally the FMDL/FV2 file to be modified using the hex editor.

Keep in mind modded FTEX files with custom names need to be placed at the minimum anywhere within the `Assets` directory, they won't work if placed in the root directory.

### Issues

Haven't added any detection/escaping for Unicode/problematic characters in input paths, so just be aware if the paths have special characters it might error or fail to input.

In this initial version there's no error checking when processing the model file through XVI32. If the hex strings aren't found XVI32 simply won't modify the file and exit, however the batch script will still state that modification is complete. Will look into this.
