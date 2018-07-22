#!/bin/bash

# based on step by step guide
# posted on August 16, 2016 by meetcareygmailcom
# https://meetcarey.wordpress.com/2016/08/16/first-blog-post/
#
# guide is for centos 7.0
# but works with centos 7.x (validated with 7.4.1708 and 7.5.1804)

LABEL="CentOS 7 x86_64"
# boot menu config needs escaped spaces (replace all spaces by \x20)
LABEL_CFG="${LABEL// /\\x20}"


######################################################################
# STEP 1 and STEPs 7,8,9,10 must be done outside the docker container.
######################################################################


### STEP 1 ###
# you have to download the iso you want to use and copy it to the /iso volume
# SOURCE_ISO="/iso/CentOS-7-x86_64-Minimal-1708.iso"
SOURCE_ISO=$1
if [ -z "$SOURCE_ISO" ]; then
    echo "SOURCE_ISO is not defined."
    exit -1
fi
if [ ! -f "$SOURCE_ISO" ]; then
    echo "$SOURCE_ISO file not found."
    exit -1
fi
# define the target file name:
TARGET_ISO=${SOURCE_ISO##*/}
TARGET_ISO=/target/${TARGET_ISO%.*}-headless.iso

# work folders:
ORIGINAL_ISO=/work/original
# for debugging use /target/custom folder and avoid cleanup:
CUSTOM_ISO=/work/custom


### STEP 2 ###
echo ""
echo "==> mount $(basename $SOURCE_ISO)"
mkdir -p $ORIGINAL_ISO
# mound needs docker run -privileged
mount -o loop,ro -t iso9660 "$SOURCE_ISO" $ORIGINAL_ISO


### STEP 3 ###
echo ""
echo "==> copy iso content to $CUSTOM_ISO"
rm -rf $CUSTOM_ISO
cp -rf $ORIGINAL_ISO/ $CUSTOM_ISO


### STEP 4 ###
echo ""
echo "==> create custom isolinux.cfg"
cat > $CUSTOM_ISO/isolinux/isolinux.cfg << EOF
# configuration for headless installation
# boot with the created bootable medium
# and install through console (tty0) or serial console (ttyS0, 115200, N, 8)

default linux
timeout 50
prompt 1

label linux
  kernel vmlinuz
  append initrd=initrd.img inst.stage2=hd:LABEL=$LABEL_CFG console=tty0 console=ttyS0,115200n8

label text
  kernel vmlinuz
  append initrd=initrd.img text inst.stage2=hd:LABEL=$LABEL_CFG console=tty0 console=ttyS0,115200n8

label check
  kernel vmlinuz
  append initrd=initrd.img inst.stage2=hd:LABEL=$LABEL_CFG rd.live.check quiet

EOF


### STEP 5 ###
echo ""
echo "==> create target $(basename $TARGET_ISO)"
cd $CUSTOM_ISO
# for debugging remove -quiet flag
# label (-volid ...) must match the label in isolinux.cfg
mkisofs -quiet -r -volid "$LABEL" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o $TARGET_ISO $CUSTOM_ISO


### STEP 6 ###
echo ""
echo "==> run isohybrid"
isohybrid $TARGET_ISO


### STEP 7 ###
echo ""
echo "==> verify $(basename $TARGET_ISO)"
file -b $TARGET_ISO
echo ""

#cleanup
echo "==> cleanup"
rm -rf $CUSTOM_ISO
umount $ORIGINAL_ISO
rm -rf $ORIGINAL_ISO
echo ""
echo "Done."
echo ""

### STEP 8 ###
# burn /target/custom.iso to the USB medium

### STEP 9 ###
# take the USB medium and boot with it

### STEP 10 ###
# install via serial console (or regular console if display is available)
