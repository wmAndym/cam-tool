#!/bin/sh
for x in {254..2}
do

echo "10.0.100.$x"

ping -c 1 -t 1 "10.0.100.$x" &

done
sleep 2
