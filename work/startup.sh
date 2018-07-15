#!/bin/bash

# create custom headless installation iso for each iso file
# found in /iso folder

total_count=0
for isofile in /iso/*.iso; do
    ((total_count++))
done

count=0
for isofile in /iso/*.iso; do
    ((count++))
    echo ""
    echo "-----------------------------------------------"
    echo "build $count/$total_count - custom iso of:"
    echo "$(basename $isofile)"
    echo "-----------------------------------------------"
    ./build_custom_iso.sh $isofile
done

if [ count == 0 ]; then
    echo "ERROR: no iso file found."
fi
