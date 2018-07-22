#!/bin/bash


if [ ! -z "$SOURCE" ]; then

    # create custom headless installation iso for the specified file only
    
    isofile=/iso/$SOURCE
    if [ ! -f "$isofile" ]; then
        echo "ERROR: source iso file $isofile not found!"
        exit -1
    fi
    
    ./build_custom_iso.sh "$isofile" "$TARGET"
    
else

    # create custom headless installation iso for all iso files
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
        echo "$count/$total_count - build custom iso of:"
        echo "$(basename $isofile)"
        echo "-----------------------------------------------"
        ./build_custom_iso.sh "$isofile"
    done

    if [ count == 0 ]; then
        echo "ERROR: no iso file found."
        exit -1
    fi
fi

exit 0
