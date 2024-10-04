#!/usr/bin/env bash

DIR=`dirname "$0"`
NAME=game_sf_template
LIB=/usr/local/lib
FRAMEWORKS=/Library/Frameworks

SFML_SYSTEM_LIB=libsfml-system.2.5.1.dylib
SFML_INCLUDE_DIR=SFML
SFML_EXTLIB=OpenAL.framework/OpenAL

# check if sfml 2.5.1 libs are installed
if ! [[ -f $LIB/$SFML_SYSTEM_LIB ]]; then
  echo "$LIB/$SFML_SYSTEM_LIB does not exist."
  echo "installing SFML libraries to $LIB ..."
  cp $DIR/sfml/lib/* $LIB
  echo "installed SFML libraries to $LIB"
fi

# check if sfml ext libs are installed
if ! [[ -f $FRAMEWORKS/$SFML_EXTLIB ]]; then
  echo "$FRAMEWORKS/$SFML_EXTLIB does not exist."
  echo "installing SFML external dependencies to $FRAMEWORKS (requires password) ..."
  sudo cp -r $DIR/sfml/extlibs/* $FRAMEWORKS
  echo "installed SFML external dependencies to $FRAMEWORKS"
fi

$DIR/$NAME.o
