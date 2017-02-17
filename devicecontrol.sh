#!/bin/bash

PATH=/bin:/sbin
KERNEL=$(uname -r)

function unmount_usb_drives {
	USB_DRIVES="$(for devlink in /dev/disk/by-id/usb*; do readlink -f ${devlink}; done)"
	for usb_drive in $USB_DRIVES; do
		echo Unmounting $usb_drive
		umount -f $usb_drive
	done
}
function disable_usb {
	echo "Disabling USB storage"
	DISABLE="mv /lib/modules/$KERNEL/kernel/drivers/usb/storage/usb-storage.ko /lib/modules/$KERNEL/kernel/drivers/usb/storage/usb-storage.backup"
	unmount_usb_drives
	rmmod uas
	rmmod usb_storage
	`$DISABLE`
}
function enable_usb {
	echo "Enabling USB storage"
	ENABLE="mv /lib/modules/$KERNEL/kernel/drivers/usb/storage/usb-storage.backup /lib/modules/$KERNEL/kernel/drivers/usb/storage/usb-storage.ko"
	`$ENABLE`
	modprobe usb_storage
}

function disable_cdrom {
	echo "Disabling CDROM"
	umount -f /dev/sr0
	DISABLE="mv /lib/modules/$KERNEL/kernel/drivers/scsi/sr_mod.ko /lib/modules/$KERNEL/kernel/drivers/scsi/sr_mod.backup"
	`$DISABLE`
	rmmod sr_mod
}

function enable_cdrom {
	echo "Enabling CDROM"
	ENABLE="mv /lib/modules/$KERNEL/kernel/drivers/scsi/sr_mod.backup /lib/modules/$KERNEL/kernel/drivers/scsi/sr_mod.ko"
	`$ENABLE`
	modprobe sr_mod
}


device="$1"
switch="$2"

case $device in
	usb)
		case $switch in
			on)
			enable_usb
			;;
			off)
			disable_usb
			;;
		esac
	;;
	cdrom)
		case $switch in
			on)
			enable_cdrom
			;;
			off)
			disable_cdrom
			;;
		esac
	;;
	*)
		echo "Usage: $0 [cdrom|usb] [on|off]"
	;;
esac
