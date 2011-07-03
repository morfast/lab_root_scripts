#!/bin/bash

source /etc/profile

URL="http://pcss.xmu.edu.cn/about_us/1_5.html"
OUTFILE="/tmp/gz.html"
LECFILE="/tmp/lec.txt"
TITLEFILE="/root/scripts/alltitles.txt"
MAILFILE="/tmp/mailgz.txt"
MAILLIST="cx8508@gmail.com "
MAILLIST="${MAILLIST} qlhuang1985@gmail.com "
MAILLIST="${MAILLIST} supi@xmu.edu.cn"
MAILLIST="${MAILLIST} hui.liu.e@gmail.com"

cp ${OUTFILE} ${OUTFILE}~
wget -q ${URL} -O ${OUTFILE}
diff ${OUTFILE} ${OUTFILE}~ && exit


#grep -A 1 '<span class="STYLE2">' ${OUTFILE} | html2text | iconv -f gbk | tr -d '\n'  | grep -o "作“[^“]*”" \
grep -A 1 '<span class="STYLE2">' ${OUTFILE} | html2text -width 10000 | iconv -f gbk > $LECFILE

while read line
do
	echo $line | grep -q "”"
	if [ $? -eq 0 ]; then
	    TITLE=$(echo $line | grep -o "作“[^“]*”" | tr -d "作” ")
	    grep -q -i "${TITLE}" $TITLEFILE
	    if [ $? -ne 0 ]; then
                echo  > $MAILFILE
                echo ${URL} >> $MAILFILE
                echo  >> $MAILFILE
	    	echo $line >> $MAILFILE
		echo "${TITLE}" >> ${TITLEFILE}
		cat $MAILFILE | mutt -s "最新讲座信息(国重)" $MAILLIST
	    fi
	fi

done < $LECFILE

