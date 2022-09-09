# MGSV Custom Texture Path Hex Replacer

Simplifies custom FTEX texture path hex replacement in FMDL/FV2 files for Metal Gear Solid V: The Phantom Pain, the manual process of which originally outlined on BobDoleOwndU's [wiki page](http://bobdoleowndu.github.io/mgsv/documentation/customtexturenames.html).

For an overview of features to this technique, an installation guide, and general usage in more detail see [the wiki](https://github.com/chocmake/MGSV-Custom-Texture-Path-Hex-Replacer/wiki). For a thorough tutorial using this technique and batch script click the graphic below.

[![wiki-guide-banner](https://user-images.githubusercontent.com/34178938/39674411-da52ed2a-518e-11e8-8428-7e9086a57ba3.png)](https://github.com/chocmake/MGSV-Custom-Texture-Path-Hex-Replacer/wiki/Re%E2%80%90texturing-a-Supply-Box)

***

Example GIF of script usage:

![script in practice-v0 3](https://user-images.githubusercontent.com/34178938/189296967-cf86d966-e023-4be5-a46a-de089166b292.gif)

***

### Dependancies

- [GzsTool (BobDoleOwndU version)](https://github.com/BobDoleOwndU/GzsTool/releases/latest) or [QuickHash](https://github.com/BobDoleOwndU/QuickHash/releases/latest)
- [XVI32 hex editor](http://www.chmaas.handshake.de/delphi/freeware/xvi32/xvi32.htm)

> Note: As of v0.3 of the script there's a setting to use QuickHash for the hex function instead. If you'd prefer to use it open the script in a text editor and change `set usequickhash=no` to `set usequickhash=yes`.

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

> Tip: if you run into any problems check if the [Troubleshooting](https://github.com/chocmake/MGSV-Custom-Texture-Path-Hex-Replacer/wiki/Troubleshooting) section of the wiki covers it.

***

### Ground Zeroes

Ground Zeroes uses a different method of writing textures to the FMDL which is far stricter and impractical for the method used by this batch script. See [FMDL Studio](https://github.com/BobDoleOwndU/FMDL-Studio-v2/wiki) for a usable alternative which supports custom paths and filenames.

***

### Known issues

- Extended ranges of Unicode is unsupported. Due to both encoding for storing the program paths in the batch script but also importantly as the XVI32 hex editor doesn't appear to read files from paths with such Unicode characters. 
