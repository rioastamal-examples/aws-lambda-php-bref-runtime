#!/bin/bash
#
realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

BASE_DIR=$( dirname "$0" )
ABS_DIR=$( realpath $BASE_DIR )

mkdir -p $ABS_DIR/build

chmod +x $ABS_DIR/src/bootstrap

rm -r $ABS_DIR/build/*.zip

cd $ABS_DIR && zip -j build/function.zip src/bootstrap src/main.php
