#!/usr/bin/env bash

set -e 

DIR="$1"
SCRIPT="$2"

echo "#!/bin/bash" >> $DIR/alt_script.sh
echo ${SCRIPT} >> $DIR/alt_script.sh
chmod u+x $DIR/alt_script.sh
bash -x $DIR/alt_script.sh
rm -rf $DIR/alt_script.sh

