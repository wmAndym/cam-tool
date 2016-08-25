#/bin/sh
LOG="/tmp/pre_uut.log"
SN=$1
CARRIER_ID=$2
LOCATION_ID=$3
IP_ADDRESS_OF_CAM=$4


echo "do the following command sets in pre uut\n" >$LOG
echo "SerialNumber:$SN\nCarrier_ID:$CARRIER_ID\nLocation:$LOCATION_ID\nIP_ADDRESS_OF_CAM:$IP_ADDRESS_OF_CAM\n" >>$LOG



function init_seq()
{
echo "#initialize sequnce" >>$LOG
echo "#FPGA_EURO_26=0" >>$LOG
/usr/bin/curl  "http://$IP_ADDRESS_OF_CAM/main.htm?FPGA_EURO_26=0" --silent --compressed --max-time 2

echo "#FPGA_EURO_27=0" >>$LOG
/usr/bin/curl  "http://$IP_ADDRESS_OF_CAM/main.htm?FPGA_EURO_27=0" --silent --compressed --max-time 2
#sleep 0.5
sleep 0.5

echo "#FPGA_EURO_22=0" >>$LOG
/usr/bin/curl  "http://$IP_ADDRESS_OF_CAM/main.htm?FPGA_EURO_22=0" --silent --compressed --max-time 2

echo "#FPGA_EURO_23=0" >>$LOG
/usr/bin/curl  "http://$IP_ADDRESS_OF_CAM/main.htm?FPGA_EURO_23=0" --silent --compressed --max-time 2

echo  "#FPGA_EURO_24=0" >>$LOG
/usr/bin/curl  "http://$IP_ADDRESS_OF_CAM/main.htm?FPGA_EURO_24=0" --silent --compressed --max-time 2

echo  "#FPGA_EURO_25=0" >>$LOG
/usr/bin/curl  "http://$IP_ADDRESS_OF_CAM/main.htm?FPGA_EURO_25=0" --silent --compressed --max-time 2

echo  "#FPGA_EURO_9=2" >>$LOG
/usr/bin/curl  "http://$IP_ADDRESS_OF_CAM/main.htm?FPGA_EURO_9=2" --silent --compressed --max-time 2

echo  "#FPGA_EURO_3=2" >>$LOG
/usr/bin/curl  "http://$IP_ADDRESS_OF_CAM/main.htm?FPGA_EURO_3=2" --silent --compressed --max-time 2

echo  "#FPGA_EURO_8=1" >>$LOG
/usr/bin/curl  "http://$IP_ADDRESS_OF_CAM/main.htm?FPGA_EURO_8=1" --silent --compressed --max-time 2

echo  "#FPGA_EURO_11=1" >>$LOG
/usr/bin/curl  "http://$IP_ADDRESS_OF_CAM/main.htm?FPGA_EURO_11=1" --silent --compressed --max-time 2

echo  "#FPGA_EURO_13=1" >>$LOG
/usr/bin/curl  "http://$IP_ADDRESS_OF_CAM/main.htm?FPGA_EURO_13=1" --silent --compressed --max-time 2

echo  "#FPGA_EURO_14=1" >>$LOG
/usr/bin/curl  "http://$IP_ADDRESS_OF_CAM/main.htm?FPGA_EURO_14=1" --silent --compressed --max-time 2

echo  "#FPGA_EURO_15=1" >>$LOG
/usr/bin/curl  "http://$IP_ADDRESS_OF_CAM/main.htm?FPGA_EURO_15=1" --silent --compressed --max-time 2

echo  "#FPGA_EURO_16=1" >>$LOG
/usr/bin/curl  "http://$IP_ADDRESS_OF_CAM/main.htm?FPGA_EURO_16=1" --silent --compressed --max-time 2

}

init_seq
