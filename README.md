# MGSV Custom Texture Path Hex Replacer

Simplifies custom FTEX texture path hex replacement in FMDL/FV2 files, the manual process of which originally outlined on BobDoleOwndU's [wiki page](http://bobdoleowndu.github.io/mgsv/documentation/customtexturenames.html).

### Dependancies

- [GzsTool (BobDoleOwndU version)](https://github.com/BobDoleOwndU/GzsTool/releases)
- [XVI32 hex editor](http://www.chmaas.handshake.de/delphi/freeware/xvi32/xvi32.htm)

![Screenshot](https://raw.githubusercontent.com/chocmake/MGSV-Custom-Texture-Path-Hex-Replacer/master/Screenshot.png)

### Installation

1. Install the required programs.
2. Download the zip from the [Releases tab](github.com/chocmake/MGSV-Custom-Texture-Path-Hex-Replacer/releases/).
3. Launch `MGSV-Custom-Texture-Path-Hex-Replacer.bat`.
4. Drag and drop the installed programs on the window as prompted to save the paths to the script.

> Tip: A user setting to show/hide the 'how to' text above the input prompts can be manually changed at the end of the batch script in a text editor. To hide the text change the `set showhowto=` value to `0`, or back to `1` to make it visible again.   

### Usage

The script can launched a few different ways:

- Opening the script by double-clicking it.
- Dropping an FMDL/FV2 file on its icon.
- Launching it from an FMDL/FV2 file via a custom [Send To](https://www.computerhope.com/tips/tip73.htm) context menu shortcut.

From there follow the prompts. The FTEX paths can either be filled by drag and dropping the files or by pasting the paths into the prompts.

### Directory structure

The script expects a directory structure like that of a unpacked file (ie: beginning from either a root directory or `Assets`), but doesn't mind if you drop a file that contains multiple unpacked file directories within each other since it will strip all but the last occurance of `Assets` for the hash.

As an example in the path below only everything following the last occurance of `Assets` will be hashed when dropped on the script (as seen in the main screenshot):

`C:\Users\Username\Desktop\chunk0_dat\Assets\tpp\pack\player\fova\plfova_sna0_face4_v00_pftxs\Assets\tpp\chara\sna\Pictures\sna_bdn0_def_bsm.ftex`

For the *Original FTEX Path* prompt a file can come either from its original location within a root directory (which contains files with already hashed names), or from within `Assets` (such as the above example path). For the *Custom FTEX Path* prompt a file must only be located somewhere within `Assets` (even within custom sub-directories), since the hash won't be recognized if located in a root directory.

### Known issues

- Unicode is unsupported. For one since batch seems to have trouble with it for storing the program paths but also importantly as the XVI32 hex editor doesn't appear to read files from paths with Unicode. 

- There's no error checking for the hex editor as it doesn't report an errorlevel (confirmed by the developer). That said, if a hex string doesn't exist XVI32 will simply not save the file and exit. Because of this I added a simple date modified timestamp comparison check after processing to inform whether the model file was updated or not (note: the standard date modified variable in the command line is only minute-accurate so currently if you unpack an FPK and within the same minute use the batch script it will erroneously state that modification is unsuccessful).
