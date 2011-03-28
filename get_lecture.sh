#!/bin/bash

source /etc/profile

LIST_URL='http://chem.xmu.edu.cn/news/sort.asp?dy1=%D7%EE%D0%C2%CD%A8%D6%AA&dy2=%D1%A7%CA%F5%BB%EE%B6%AF'
LIST_FILE='/tmp/lecturelist.html'
LINE_PATTERN=".gif 现在是 厦门大学化学化工学院新闻系统 Copyright "
WORD_PATTERN="双击自动滚屏"
MAILFILE="/tmp/mail.txt"
LATEST_LECTURE_NO_FILE="/root/scripts/latestlecno.txt"
MAILLIST="cx8508@gmail.com "
#MAILLIST="${MAILLIST} qlhuang1985@gmail.com "
#MAILLIST="${MAILLIST} supi@xmu.edu.cn"


rm -f ${LIST_FILE}
wget -q ${LIST_URL} -O ${LIST_FILE}
LATEST_LECTURE=$(grep -o -e 'news.asp?id=[0-9]*' ${LIST_FILE} | awk -F'=' '{print $2}' | head -1)
#echo ${LATEST_LECTURE}
#LATEST_LECTURE=901

if [ ${LATEST_LECTURE} -le $(cat $LATEST_LECTURE_NO_FILE) ]; then
	exit 0
fi

echo ${LATEST_LECTURE} > ${LATEST_LECTURE_NO_FILE}

LATEST_LECTURE_URL="http://chem.xmu.edu.cn/news/news.asp?id=${LATEST_LECTURE}"
LATEST_LECTURE_FILE="/tmp/latestlecture.html"
LATEST_LECTURE_FILE_TXT="/tmp/latestlecture.txt"
wget -q ${LATEST_LECTURE_URL} -O ${LATEST_LECTURE_FILE}
html2text -width 80 ${LATEST_LECTURE_FILE} | iconv -f gb2312 -t utf8 -c > $LATEST_LECTURE_FILE_TXT
#iconv -f gb2312 -t utf8 ${LATEST_LECTURE_FILE} | html2text -width 120  > $LATEST_LECTURE_FILE_TXT

for pattern in ${LINE_PATTERN}
do
    sed -i "/$pattern/d" $LATEST_LECTURE_FILE_TXT
done

for pattern in ${WORD_PATTERN}
do
    sed -i "s/${pattern}//g" $LATEST_LECTURE_FILE_TXT
done

sed -i -e "s/.\o010//g" $LATEST_LECTURE_FILE_TXT

echo  > $MAILFILE
echo ${LATEST_LECTURE_URL} >> $MAILFILE
cat $LATEST_LECTURE_FILE_TXT >> $MAILFILE

cat $MAILFILE | mutt -s "最新讲座信息" $MAILLIST
