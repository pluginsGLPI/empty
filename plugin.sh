#!/bin/bash
#
# -------------------------------------------------------------------------
# {NAME} plugin for GLPI
# Copyright (C) {YEAR} by the {NAME} Development Team.
# -------------------------------------------------------------------------
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# --------------------------------------------------------------------------
#

if [[ $# -ne 2 && $# -ne 3 ]]; then
    echo $0: usage: plugin.sh name version [destination/path]
    exit 1
fi

if [[ $# -eq 3 ]]; then
    DIR=$3
    if [ ! -d "$DIR" ]; then
        echo "Destination directory $DIR does not exists!"
        exit
    fi
else
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."
fi

NAME=$(echo $1|tr -dc '[[:alpha:]]')
LNAME=$(echo "$NAME" | tr '[:upper:]' '[:lower:]')
UNAME=$(echo "$NAME" | tr '[:lower:]' '[:upper:]')
VERSION=$2
YEAR=$(date +%Y)

DEST="$DIR/$LNAME"
echo "Creating new $NAME plugin..."

if [ -d "$DEST" ]; then
    echo "A directory named $LNAME already exists!"
    exit 1
fi

mkdir "$DEST"

rsync \
    --exclude '.git' \
    --exclude 'plugin.sh' \
    --exclude 'dist' \
    --exclude 'README.md' \
    -a . "$DEST"

pushd "$DEST" > /dev/null

# Remove .tpl suffix (current folder and subdirectories)
# Note: the .tpl suffix is used to prevent some files from being detected by
# GLPI (like the setup.php) or github (the ci configuration).
find . -type f -name "*.tpl" -exec bash -c 'mv "$0" "${0%.*}"' {} \;

# move xml file
mv plugin.xml $LNAME.xml

#do replacements
sed \
    -e "s/{NAME}/$NAME/g" \
    -e "s/{LNAME}/$LNAME/g" \
    -e "s/{UNAME}/$UNAME/g" \
    -e "s/{VERSION}/$VERSION/g" \
    -e "s/{YEAR}/$YEAR/g" \
    -i setup.php hook.php $LNAME.xml tools/HEADER README.md Makefile .github/workflows/continuous-integration.yml tests/bootstrap.php rector.php composer.json

# Remove composer lock
sed -i '/^[[:space:]]*composer\.lock[[:space:]]*$/d' .gitignore

popd > /dev/null
