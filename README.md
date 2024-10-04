# Mini Monsters

[![Ludum Dare 56](https://img.shields.io/badge/LudumDare-56-f79122?labelColor=ee5533&link=https%3A%2F%2Fldjam.com%2Fevents%2Fludum-dare%2F56)](https://ldjam.com/events/ludum-dare/56)

This game is being made for [Ludum Dare 56](https://ldjam.com/events/ludum-dare/56). Ludum Dare ([rules](https://ldjam.com/events/ludum-dare/rules)) is a 72 hour game jam.

It's being made with the [crystal](https://crystal-lang.org/) programming langauge using C++ [SFML (Simple and Fast Multimedia Library)](https://www.sfml-dev.org/) via crystal bindings via [crsfml](https://github.com/oprypin/crsfml) and a wrapper and helper framework [game_sf](https://github.com/mswieboda/game_sf).

## Installation

### Windows

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


### Mac or Linux

[install SFML](https://github.com/oprypin/crsfml#install-sfml)

```
shards install
```


## Linter

only works on Mac or Linux since shards post install is skipped on Windows.

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

zips up SFML DLLs, assets, `run.bat` (basically the .exe) to `build/mini_monsters-win.zip`

#### Mac

```
make macpack
```

creates Mac OSX release build, packages and zips

you'll need installed:
- `7zz` ([7zip](https://www.7-zip.org/) binary) via `brew install 7zip`
- `platypus` ([Platypus](https://sveinbjorn.org/platypus) binary) via `brew install --cask platypus` then in `Platypus > Preferences` install the command line tool

zips up SFML libs, ext libs, assets, `mini_monsters.app` (created by [Platypus](https://sveinbjorn.org/platypus)) to `build/mini_monsters-mac.zip`
