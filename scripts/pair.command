#/bin/sh
LOG="/tmp/pair.log"
CARRIER_ID=$1
LOCATION_ID=$2
CAM_ID=$3


echo "Carrier_ID:$CARRIER_ID\nLocation:$LOCATION_ID\nCAM_ID:$CAM_ID\n" >$LOG
/usr/local/wabisabi/kintsugi/fixtures/CAM/bin/racklistener -f $LOCATION_ID
echo "/usr/local/wabisabi/kintsugi/fixtures/CAM/bin/racklistener -f $LOCATION_ID\n" >>$LOG
