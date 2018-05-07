# MGSV Custom Texture Path Hex Replacer

Simplifies custom FTEX texture path hex replacement in FMDL/FV2 files, the manual process of which originally outlined on BobDoleOwndU's [wiki page](http://bobdoleowndu.github.io/mgsv/documentation/customtexturenames.html).

For an overview of features to this technique, an installation guide, and general usage in more detail see [the wiki](https://github.com/chocmake/MGSV-Custom-Texture-Path-Hex-Replacer/wiki). For a thorough tutorial using this technique and batch script click the graphic graphic below.

[![wiki-guide-banner](https://user-images.githubusercontent.com/34178938/39674411-da52ed2a-518e-11e8-8428-7e9086a57ba3.png)](https://github.com/chocmake/MGSV-Custom-Texture-Path-Hex-Replacer/wiki/Re%E2%80%90texturing-a-Supply-Box)

***

Example GIF of script usage:

![script in practice](https://user-images.githubusercontent.com/34178938/39673073-f88aea88-5178-11e8-836d-08b1bda91ac2.gif)

***

### Dependancies

- [GzsTool (BobDoleOwndU version)](https://github.com/BobDoleOwndU/GzsTool/releases)
- [XVI32 hex editor](http://www.chmaas.handshake.de/delphi/freeware/xvi32/xvi32.htm)

***

### Installation

1. Install the required programs.
2. Download the top zip from the [Releases tab](https://github.com/chocmake/MGSV-Custom-Texture-Path-Hex-Replacer/releases/latest).
3. Launch `MGSV-Custom-Texture-Path-Hex-Replacer.bat`.
4. Drag and drop the installed programs on the window as prompted to save the paths to the script.

***

### Usage

The script can launched a few different ways:

- Opening the script by double-clicking it.
- Dropping an FMDL/FV2 file on its icon.
- Launching it from an FMDL/FV2 file via a custom [Send To](https://github.com/chocmake/MGSV-Custom-Texture-Path-Hex-Replacer/wiki/Using-the-script#optional-adding-a-shortcut-to-the-send-to-menu) context menu shortcut.

From there follow the prompts. The FTEX paths can either be filled by drag and dropping the files or by pasting the paths into the prompts.

***

### Known issues

- Unicode is unsupported. For one since batch seems to have trouble with it for storing the program paths but also importantly as the XVI32 hex editor doesn't appear to read files from paths with Unicode. 

- If the model file was previously modified (or created via unpacking) within the same minute it's edited in the batch script the message will state the process has been unsuccessful even if it has been successful. This is due to the only minute-accurate Date Modified timestamp variable available to the command line, and the lack of error reporting from the hex editor used.
