# Project guide

## Overview

This repository contains an AutoHotkey v1 script for automating selected Genshin Impact inputs.

- `genshin.ahk`: main script and source of truth.
- `build.bat`: builds the executable from the repository root.
- `genshin.exe`: compiled output; the build overwrites this file.
- `AutoHotkey_Build/Compiler/Ahk2Exe.exe`: bundled compiler used by the build script.
- `AutoHotkey_Build/`: bundled AutoHotkey v1 runtime, compiler, and SciTE tools.
- `*.ico`: icon assets. The build command currently uses `temp_260416_222240_2.ico`.
- `genshin.ahk.bak`: local backup; excluded from Git by `.gitignore`.

## Build

Run `build.bat` from the repository root. It compiles `genshin.ahk` into `genshin.exe` and embeds the icon specified in the batch command. Keep source changes in `genshin.ahk`; do not hand-edit the generated executable.

## Editing notes

- The script uses AutoHotkey v1 syntax and is encoded as UTF-8 with a BOM. Preserve that encoding when editing Korean comments or saving the file.
- The script implements F-key repetition, X1-triggered left-click and alternating Q/E repetition, and X2-triggered left-click repetition. Repeat intervals are configured near the top of `genshin.ahk`.
- Check the actual timer wiring before changing game-window detection: `RepeatT` is present, but its `SetTimer` call is commented out; `RecheckTimerEvent()` currently returns before its process check.
- Keep changes focused. The bundled `AutoHotkey_Build` directory is the toolchain, not project source.

## Verification

There is no test suite configured. For changes to the script, inspect the diff and, when a compiled deliverable is needed, run `build.bat` and verify the resulting executable exists.
