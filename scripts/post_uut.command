#/bin/sh
LOG="/tmp/post_uut.log"
SN=$1
CARRIER_ID=$2
LOCATION_ID=$3
IP_ADDRESS_OF_CAM=$4


echo "do the following command sets in post uut\n" >$LOG
echo "SerialNumber:$SN\nCarrier_ID:$CARRIER_ID\nLocation:$LOCATION_ID\nIP_ADDRESS_OF_CAM:$IP_ADDRESS_OF_CAM\n" >$LOG