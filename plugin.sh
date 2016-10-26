#!/bin/bash

if [[ $# -ne 2 ]]; then
    echo $0: usage: plugin.sh name version
    exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NAME=$1
LNAME=${NAME,,}
UNAME=${NAME^^}
VERSION=$2

DEST=$DIR/../$LNAME
echo $NAME

if [ -d "$DEST" ]; then
    echo "A directory named $LNAME already exists!"
    exit 1
fi

mkdir $DEST
#copy all files
cp -a . $DEST

pushd $DEST > /dev/null
#remove initialization script
rm plugin.sh

#do replacements
sed \
    -e "s/{NAME}/$NAME/" \
    -e "s/{LNAME}/$LNAME/" \
    -e "s/{UNAME}/$UNAME/" \
    -e "s/{VERSION}/$VERSION/" \
    -i setup.php hook.php tools/extract_template.sh
popd > /dev/null
