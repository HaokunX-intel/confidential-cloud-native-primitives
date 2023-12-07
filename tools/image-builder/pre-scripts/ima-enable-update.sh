#!/bin/sh

GRUB_FILE=/etc/default/grub.d/50-cloudimg-settings.cfg
GRUB_FILE_NEW=$GRUB_FILE".new"
awk '{if($1 ~ /GRUB_CMDLINE_LINUX_DEFAULT/) sub("=\"","=\"ima_appraise=fix ima_policy=appraise_tcb "); print}' \
    $GRUB_FILE \
    > $GRUB_FILE_NEW
mv $GRUB_FILE_NEW $GRUB_FILE
update-grub

 