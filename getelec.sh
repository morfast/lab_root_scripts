#!/bin/bash

source /etc/profile

date=$(date +%F)
maillist="cx8508@gmail.com 13950137793@139.com"
#qlhuang1985@gmail.com 15859292952@139.com
#maillist="13950137793@139.com"
roomno="07010310"

wget -q "http://elec.xmu.edu.cn/power.asp?RoomCode=$roomno&StartDate=$date&EndDate=$date&R=0.$RANDOM" -O elec_$date

if [ $? -eq 0 ]; then
    power=$(iconv -c -f gb2312 -t utf8 elec_$date | grep -A 1 "当前剩余电量" | tail -1 | grep -o -e "[0-9]*\.[0-9]*")
    powerint=${power%.*}
    if [ $powerint -lt 8 ]; then
        echo "还有$power度电，快去充。宿舍号$roomno" | mutt -s "要充电费啦" $maillist
    fi
    rm -f elec_$date 
fi

