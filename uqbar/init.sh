#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <name>"
    exit 1
fi

NAME="$1"

git clone https://github.com/uqbar-dao/app_template.git $NAME
rm -rf $NAME/.git
LANG=C.UTF-8 find ./$NAME -type f -exec sed -i '' -e "s/__NAME__/$NAME/g" {} \;
