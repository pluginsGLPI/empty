#!/bin/bash

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
LNAME=${NAME,,}
UNAME=${NAME^^}
VERSION=$2
YEAR=$(date +%Y)

DEST=$DIR/$LNAME
echo "Creating new $NAME plugin..."

if [ -d "$DEST" ]; then
    echo "A directory named $LNAME already exists!"
    exit 1
fi

mkdir $DEST

rsync \
    --exclude '.git' \
    --exclude 'plugin.sh' \
    --exclude 'dist' \
    --exclude 'README.md' \
    -a . $DEST

pushd $DEST > /dev/null

#rename .tpl...
for f in `ls *.tpl`
do
    mv $f ${f%.*}
done

#drop specific file config from RoboFile
sed -e "/^.*protected \$csfiles.*$/d" -i RoboFile.php

# move xml file
mv plugin.xml $LNAME.xml

#do replacements
sed \
    -e "s/{NAME}/$NAME/" \
    -e "s/{LNAME}/$LNAME/" \
    -e "s/{UNAME}/$UNAME/" \
    -e "s/{VERSION}/$VERSION/" \
    -e "s/{YEAR}/$YEAR/" \
    -i setup.php hook.php $LNAME.xml tools/HEADER README.md .travis.yml

popd > /dev/null
