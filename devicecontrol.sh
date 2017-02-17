#!/bin/bash

KERNEL=$(uname -r)

function unmount_usb_drives {
	USB_DRIVES="$(for devlink in /dev/disk/by-id/usb*; do readlink -f ${devlink}; done)"
	for usb_drive in $USB_DRIVES; do
		echo Unmounting $usb_drive
		/bin/umount -f $usb_drive
	done
}
function disable_usb {
	echo "Disabling USB storage"
	DISABLE="/bin/mv /lib/modules/$KERNEL/kernel/drivers/usb/storage/usb-storage.ko /lib/modules/$KERNEL/kernel/drivers/usb/storage/usb-storage.backup"
	/bin/unmount_usb_drives
	/sbin/rmmod uas
	/sbin/rmmod usb_storage
	`$DISABLE`
}
function enable_usb {
	echo "Enabling USB storage"
	ENABLE="/bin/mv /lib/modules/$KERNEL/kernel/drivers/usb/storage/usb-storage.backup /lib/modules/$KERNEL/kernel/drivers/usb/storage/usb-storage.ko"
	`$ENABLE`
	/sbin/modprobe usb_storage
}

function disable_cdrom {
	echo "Disabling CDROM"
	/bin/umount -f /dev/sr0
	DISABLE="/bin/mv /lib/modules/$KERNEL/kernel/drivers/scsi/sr_mod.ko /lib/modules/$KERNEL/kernel/drivers/scsi/sr_mod.backup"
	`$DISABLE`
	/sbin/rmmod sr_mod
}

function enable_cdrom {
	echo "Enabling CDROM"
	ENABLE="/bin/mv /lib/modules/$KERNEL/kernel/drivers/scsi/sr_mod.backup /lib/modules/$KERNEL/kernel/drivers/scsi/sr_mod.ko"
	`$ENABLE`
	/sbin/modprobe sr_mod
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
