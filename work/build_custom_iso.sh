#!/bin/bash

# based on step by step guide
# posted on August 16, 2016 by meetcareygmailcom
# https://meetcarey.wordpress.com/2016/08/16/first-blog-post/
# guide is for centos 7.0
# but works with centos 7.x (validated with 7.4.1708 and 7.5.1804)
#
# further resources:
# https://serverfault.com/questions/517908/how-to-create-a-custom-iso-image-in-centos?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
# 
# 
# parameters:
# $1        source iso file (required)
# $KS_CFG   kickstart file (optional)
#


### PARAMETERS ###

# Required source iso file (script parameter).
if [ -z "$1" ]; then
    echo "ERROR: SOURCE_ISO is not defined!"
    exit -1
fi
SOURCE_ISO=$1
if [ ! -f "$SOURCE_ISO" ]; then
    echo "ERROR: $SOURCE_ISO file not found!"
    exit -1
fi

# Optional target iso file name (script parameter).
if [ -z "$2" ]; then
    # if target iso is not defined, use the same filename as source
    TARGET_ISO=/target/$(basename "$SOURCE_ISO")
else
    TARGET_ISO=/target/$2
fi

# Optional kickstart file (environment variable)
# Define default kickstart file /custom/ks.cfg
# or validate the given kickstart file exists
if [ -z "$KS_CFG" ]; then
    KS_CFG=ks.cfg
else
    if [ ! -f /custom/$KS_CFG ]; then
        echo "ERROR: kickstart file /custom/$KS_CFG not found!"
        exit -2
    fi
fi


### CONFIGURATION ###
LABEL="CentOS 7 x86_64"
# inst.stage2 needs escaped spaces for the label (replace all spaces by \x20)
LABEL_CFG="${LABEL// /\\x20}"

# Definition of work folders
ORIGINAL_ISO=/work/original
# for debugging use /target/custom folder and avoid cleanup:
CUSTOM_ISO=/work/custom

SOURCE_KS_CFG=/custom/$KS_CFG
TARGET_KS_CFG=$CUSTOM_ISO/isolinux/ks.cfg
SOURCE_RPM_DIR=/custom/$RPM_DIR
TARGET_RPM_DIR=$CUSTOM_ISO/Packages

# if RPM_DIR is specified but not found terminate with error
if [ ! -z "$RPM_DIR" ]; then
    if [ ! -d $SOURCE_RPM_DIR ]; then
        echo "ERROR: rpm folder $SOURCE_RPM_DIR not found!"
        exit -3
    fi
fi



### STEP 2 ###
echo ""
echo "==> mount $(basename "$SOURCE_ISO")"
mkdir -p $ORIGINAL_ISO
# mount needs docker run -privileged
mount -o loop,ro -t iso9660 "$SOURCE_ISO" $ORIGINAL_ISO


### STEP 3 ###
echo ""
echo "==> copy iso content to $CUSTOM_ISO"
rm -rf $CUSTOM_ISO
cp -rf $ORIGINAL_ISO/ $CUSTOM_ISO
chmod -R u+w $CUSTOM_ISO


### optional: use kickstart file
KS=""
if [ -f $SOURCE_KS_CFG ]; then
	echo ""
	echo "==> configure kickstart"
	echo "    validate kickstart file $(basename $SOURCE_KS_CFG)"
    ksvalidator -e $SOURCE_KS_CFG
    
	cp $SOURCE_KS_CFG $TARGET_KS_CFG
    KS="inst.ks=hd:LABEL=$LABEL_CFG:/isolinux/$(basename $TARGET_KS_CFG)"
    echo "    kickstart: $KS"
fi


### optional: add rpm files to repository
if [ -d $SOURCE_RPM_DIR ]; then
    echo ""
	echo "==> add rpm files from $SOURCE_RPM_DIR to repo"
    rpm_files=0
    for file in $SOURCE_RPM_DIR/*.rpm; do
        ((rpm_files++))
    done
    if [ $rpm_files == 0 ]; then
        echo "WARNING: no rpm files found in $RPM_DIR!"
    else
        ### Add RPM Files to repository on the installation media ###
        if [ $rpm_files == 1 ]; then
            echo "    add $file"
        else
            echo "    add $rpm_files rpm files"
        fi
        # remove exec attr added by windows os...
        chmod -x $SOURCE_RPM_DIR/*.rpm
        # Copy additional RPMs to the directory structure.
        mkdir -p $TARGET_RPM_DIR
        cp -n $SOURCE_RPM_DIR/*.rpm $TARGET_RPM_DIR/.
        # Update repository metadata with added files (keep group definitions)
        cd $CUSTOM_ISO
        for file in repodata/*comps.xml; do
            echo "    update $(basename $file)"
            createrepo --quiet --update -g $file .
        done
    fi
fi



### STEP 4 ###
echo ""
echo "==> create custom isolinux.cfg"
cat > $CUSTOM_ISO/isolinux/isolinux.cfg << EOF
# configuration for headless installation
# boot with the created bootable medium
# and install through console (tty0) or serial console (ttyS0, 115200, N, 8)
# with kickstart a fully automated installation is possible

default linux
timeout 1

label linux
  kernel vmlinuz
  append initrd=initrd.img $KS inst.stage2=hd:LABEL=$LABEL_CFG console=tty0 console=ttyS0,115200n8

EOF


### STEP 5 ###
echo ""
echo "==> create target $(basename "$TARGET_ISO")"
cd $CUSTOM_ISO
# for debugging remove -quiet flag
# label (-volid ...) must match the label in isolinux.cfg
mkisofs -quiet -r -volid "$LABEL" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o "$TARGET_ISO" $CUSTOM_ISO


### STEP 6 ###
echo ""
echo "==> run isohybrid"
isohybrid "$TARGET_ISO"


### STEP 7 ###
echo ""
echo "==> verify $(basename "$TARGET_ISO")"
file -b "$TARGET_ISO"


### 
echo ""
echo "==> implant md5 into $(basename "$TARGET_ISO")"
implantisomd5 "$TARGET_ISO" >> /dev/null


### cleanup
echo ""
echo "==> cleanup"
rm -rf $CUSTOM_ISO
umount $ORIGINAL_ISO && rmdir $ORIGINAL_ISO


### Done.
echo ""
echo "Done."
echo ""
