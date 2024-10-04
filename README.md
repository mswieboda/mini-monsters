# Game SF Template

## Rename

Currently only works on Mac or Linux.

To use this template, use the rename script, and follow the prompts, to automatically replace all text, and rename all files and folders from the example of `GameSFTemplate`, `game_sf_template` and `Game SF Template`.

```
make rename
```

The rename won't work on Windows until using the command line prompt works, I could in the meantime make a custom batch script, but I probably won't do that for now.

## Installation

## Windows

if compiling/installing from Windows, in an `x64 Native Tools Command Prompt for VS 2019` command line (see [https://github.com/mswieboda/game_sf?tab=readme-ov-file#installation](game_sf) Windows Installation instructions) please first run:

```
win_shards_install.bat
```

to install shards and clone crsfml v2.5.3 and compile it for windows directly

then run:

```
win_shards_postinstall.bat
```

to copy the specific Window crsfml v2.5.3 compiled files to this `lib/crsfml`


## Mac or Linux

[install SFML](https://github.com/oprypin/crsfml#install-sfml)

```
shards install
```


### Linter

```
bin/ameba
```

or

```
bin/ameba --fix
bin/ameba --gen-config
```
etc, see [ameba](https://github.com/crystal-ameba/ameba)

## Compiling

### Dev / Test

```
make
```

or

```
make test
```

### Release

```
make release
```

### Packaging

#### Windows

creates Windows release build, packages and zips

```
make winpack
```

you'll need `7z` ([7zip](https://www.7-zip.org/) binary) installed ([download](https://www.7-zip.org/))

zips up SFML DLLs, assets, `run.bat` (basically the .exe) to `build/game_sf_template-win.zip`

#### Mac

```
make macpack
```

creates Mac OSX release build, packages and zips

you'll need installed:
- `7zz` ([7zip](https://www.7-zip.org/) binary) via `brew install 7zip`
- `platypus` ([Platypus](https://sveinbjorn.org/platypus) binary) via `brew install --cask platypus` then in `Platypus > Preferences` install the command line tool

zips up SFML libs, ext libs, assets, `game_sf_template.app` (created by [Platypus](https://sveinbjorn.org/platypus)) to `build/game_sf_template-mac.zip`
