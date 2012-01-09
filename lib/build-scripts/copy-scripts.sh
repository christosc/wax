#!/bin/zsh

# Created by Corey Johnson

WAX_SCRIPTS_DIR="lib"
SOURCE_SCRIPTS_DIR="$PROJECT_DIR/$WAX_SCRIPTS_DIR"
DESTINATION_SCRIPTS_DIR="$BUILT_PRODUCTS_DIR/$CONTENTS_FOLDER_PATH/$WAX_SCRIPTS_DIR"

# Verify that the user isn't using an old version of Wax
if [ -d "$PROJECT_DIR/data/scripts" ]; then
  echo "error: Wax 1.0 changes the Lua loadpath."
  echo "error: Wax won't look for Lua scripts in '$PROJECT_DIR/data/scripts' instead, place all your scripts in '$SOURCE_SCRIPTS_DIR'"
  exit 1
fi

# If the user has luac installed, preparse the lua files and make sure they are cool
if type luac &> /dev/null; then;
  LUAC_OUTPUT=$(luac -p -- "$SOURCE_SCRIPTS_DIR"/**/*.lua 2>&1)
  LUAC_EXIT_VALUE=$?
  if [ $LUAC_EXIT_VALUE != 0 ] ; then
    echo "\n\n--------------------ERROR--------------------"
    echo "Lua Scripts were not compiled correctly!"
    echo "error::: ${LUAC_OUTPUT}"
    echo "--------------------ERROR--------------------\n\n"
    exit 1
  fi
fi

mkdir -p "$SOURCE_SCRIPTS_DIR"
rm -rf "$DESTINATION_SCRIPTS_DIR"
mkdir -p "$DESTINATION_SCRIPTS_DIR"

if [ $WAX_COMPILE_SCRIPTS ]; then
  # -- this part of the script has been moved to: $PROJECT_DIR/bin/compile-scripts
  "$PROJECT_DIR/bin/compile-scripts" "$PROJECT_DIR" "$WAX_SCRIPTS_DIR" "$DESTINATION_SCRIPTS_DIR" "$PRODUCT_NAME"
else
  # copy everything in the data dir to the app (doesn't just have to be lua files, can be images, sounds, etc...)
  cp -r "$PROJECT_DIR/wax/lib/stdlib" "$DESTINATION_SCRIPTS_DIR/wax"
  cp -r "$SOURCE_SCRIPTS_DIR/" "$DESTINATION_SCRIPTS_DIR"
fi

# This forces xcode to load all the Lua scripts (without having to clean
# the project first"
THE_FUTURE=$(date -v +1M -j +"%m%d%H%M")
touch -t $THE_FUTURE "$BUILT_PRODUCTS_DIR/$CONTENTS_FOLDER_PATH"/*.plist

# Note:
# It's handy to see the env of the build processes, there is some good stuff in there!
env
