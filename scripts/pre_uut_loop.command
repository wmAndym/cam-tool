#/bin/sh
LOG="/tmp/pre_uut_loop.log"
APP="/usr/local/wabisabi/monitor/fixtures/CAM/bin/racklistener"

function killAppByPID()
{
pid=$1
if [[ -nz $pid ]];then
echo "kill -9 $pid" >>$LOG
kill -9 $pid
fi
}

function killAllRackListener(){
for slot in {1..10}
do
#echo 'ps aux | grep slot$slot | awk "{print $2}" | head -1'
slot_pid=`ps aux | grep "slot$slot" | awk '{print $2}' | head -1`
killAppByPID $slot_pid
done
}

function checkRacklistenerLaunchedForFixture()
{
	fixture=$1
	let "slot1=$fixture*2-1"
	let "slot2=$fixture*2"
	fixture_slot1=`ps aux | grep "$slot1.log" | wc -l`
	fixture_slot2=`ps aux | grep "$slot2.log" | wc -l`

	if [[ $fixture_slot1 -gt 1 ]] && [[ $fixture_slot2 -gt 1 ]];then
		echo "found racklisten on  slot$x" >>$LOG
	else
		echo "run /usr/local/wabisabi/monitor/fixtures/CAM/bin/racklistener -f $fixture_id" >>$LOG
		$APP -f $fixture_id &
	fi
}

function main()
{
	
	if ! [[ -x $APP ]]; then
			echo "Not found App: $APP" 
			echo "Not found App: $APP" >>$LOG
			return 1
	fi

	for x in {1..5}
	do
		checkRacklistenerLaunchedForFixture $x
	done
}

#killAllRackListener
#echo "do the following command sets in pre uut loop" >$LOG

#/usr/local/wabisabi/kintsugi/fixtures/CAM/bin/racklistener -f 0
#main

