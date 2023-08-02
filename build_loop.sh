#!/bin/sh
# A simple loop to keep from delving into cursed makefile syntax

# Create a folder "target" for the binaries if it doesn't already exist
[ -d "target" ] || mkdir target

# Escape the loop var with quotes in case any files have spaces in their names
FILENAME=
for file in src/*; do
    FILENAME=$(basename "${file%.s}")
    echo "$FILENAME"
    dasm "$file" -f3 -v0 -o"$FILENAME.bin"
done

echo "Moving all binaries to target..."
mv -v *.bin target
echo "Done. Run binaries with \"stella <binary>.bin\""
