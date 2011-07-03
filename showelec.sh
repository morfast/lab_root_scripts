#!/bin/bash


date=$(date +%F)
roomno="07010310"
outfile="elec_$date_$roomno"

echo "wgetting data..."
wget -q "http://elec.xmu.edu.cn/power.asp?RoomCode=$roomno&StartDate=$date&EndDate=$date&R=0.$RANDOM" -O $outfile

if [ $? -eq 0 ]; then
    power=$(iconv -c -f gb2312 -t utf8 $outfile | grep -A 1 "当前剩余电量" | tail -1 | grep -o -e "[0-9]*\.[0-9]*")
    echo $power
    #rm -f elec_$date 
else
    echo "error"
    exit 1
fi

