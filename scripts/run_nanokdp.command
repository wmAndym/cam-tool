#!/bin/sh
# run nanokdp in another terminal application ---2015/11/23 Jifu

BUNDLE_PATH=`dirname "$0"`
SERIAL_PORT_DESCRIPTOR=`defaults read "com.sifo-ltd.CAMTOOL" "SELECTED_SLOT_MAC_ADDRESS" `
KDP=${BUNDLE_PATH}/nanokdp
if ! [[ -e "${KDP}" ]];then
	echo "nanokdp does not exist";
	exit 
fi
if ! [[ -x "${KDP}" ]];then
echo "nanokdp does not  Exceuteable,will change to ";
chmod +x "$KDP"
fi

echo "\\n$KDP -c  1250000,N,8,1 -d /dev/cu.usbserial-${SERIAL_PORT_DESCRIPTOR}\\n";

"$KDP" -c  1250000,N,8,1 -d "/dev/cu.usbserial-${SERIAL_PORT_DESCRIPTOR}"
