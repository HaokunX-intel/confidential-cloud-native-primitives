#!/bin/sh

FSTAB_FILE=/etc/fstab
FSTAB_FILE_NEW=$FSTAB_FILE".new"
awk '{if($3 == "ext4" && $4 !~ /iversion/) $4 = $4",iversion"; print}' \
    $FSTAB_FILE \
    > $FSTAB_FILE_NEW
mv $FSTAB_FILE_NEW $FSTAB_FILE

GRUB_CFG="/etc/default/grub.d/60-ccnp-setting.cfg"
GRUB_CFG_NEW="$GRUB_CFG.new"
GRUB_CFG_TEMPLATE=""

read -r -d '' GRUB_CFG_TEMPLATE << EOM
# CCNP image specific Grub settings for CCNP Images
# CCNP_IMG: This file was created/modified by the tools/cvm-image-rewriter/run.sh 
# from https://github.com/intel/confidential-cloud-native-primitives

GRUB_CMDLINE_LINUX_DEFAULT="\$GRUB_CMDLINE_LINUX_DEFAULT"
EOM

if ! [ -f "$GRUB_CFG" ]; then
    # create grub cfg file
    echo "$GRUB_CFG_TEMPLATE" > "$GRUB_CFG"
else 
    # clear grub cfg file
    sed -i 's/ima_appraise=\(fix\|enforce\|log\|off\)//' $GRUB_CFG
    sed -i 's/ima_hash=sha384//' $GRUB_CFG
    sed -i 's/rootflags=i_version//' $GRUB_CFG
    sed -i 's/console=tty1 console=ttyS0//' $GRUB_CFG
    sed -i 's/console=hvc0//' $GRUB_CFG
fi

# update kernel cmdline
PARAMETERS="console=tty1 console=ttyS0 ima_appraise=fix ima_hash=sha384 rootflags=i_version"
awk -v parameters="$PARAMETERS" '{if($1 ~ /GRUB_CMDLINE_LINUX_DEFAULT/) sub("\"$", " "parameters"\""); print}' \
    $GRUB_CFG \
    > $GRUB_CFG_NEW
mv $GRUB_CFG_NEW $GRUB_CFG

update-grub
