#!/bin/bash

source /etc/profile

LIST_URL='http://chem.xmu.edu.cn/news/sort.asp?dy1=%D7%EE%D0%C2%CD%A8%D6%AA&dy2=%D1%A7%CA%F5%BB%EE%B6%AF'
LIST_FILE='/tmp/lecturelist.html'
LINE_PATTERN=".gif 现在是 厦门大学化学化工学院新闻系统 Copyright "
WORD_PATTERN="双击自动滚屏"
MAILFILE="/tmp/mail.txt"
LATEST_LECTURE_NO_FILE="/root/scripts/latestlecno.txt"
MAILLIST="cx8508@gmail.com "
MAILLIST="${MAILLIST} qlhuang1985@gmail.com "
MAILLIST="${MAILLIST} supi@xmu.edu.cn"
MAILLIST="${MAILLIST} hui.liu.e@gmail.com"
TITLEFILE="/root/scripts/alltitles.txt"


rm -f ${LIST_FILE}
wget -q ${LIST_URL} -O ${LIST_FILE}
LATEST_LECTURES=$(grep -o -e 'news.asp?id=[0-9]*' ${LIST_FILE} | awk -F'=' '{print $2}' )
THE_LATEST_LECTURE=$(grep -o -e 'news.asp?id=[0-9]*' ${LIST_FILE} | awk -F'=' '{print $2}' | head -1 )
echo ${LATEST_LECTURES} 

for LATEST_LECTURE in $LATEST_LECTURES
do
    #LATEST_LECTURE=901
    if [ ! -f ${LATEST_LECTURE_NO_FILE} ]; then
    	echo > ${LATEST_LECTURE_NO_FILE}
    fi

    LATEST_LECTURE_NO=$(cat $LATEST_LECTURE_NO_FILE)
    
    if [ ! ${LATEST_LECTURE_NO} ]; then
    	echo ${THE_LATEST_LECTURE} > ${LATEST_LECTURE_NO_FILE}
	exit 0
    fi
    
    if [ ${LATEST_LECTURE} -le ${LATEST_LECTURE_NO} ]; then
    	break
    fi
    
    
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

    TITLE=$(grep "题 *目" ${MAILFILE} | sed "s/^.*：//g" | sed "s/^.*://g" | sed "s/[ \n]*$//g" | tr -d " ")
    
    echo $TITLE

    grep -i -q "$TITLE" ${TITLEFILE}
    if [ $? -ne 0 ]; then
    	echo ${TITLE} >> ${TITLEFILE} 
    	cat $MAILFILE | mutt -s "最新讲座信息(化院)" $MAILLIST
    	#cat $MAILFILE
    fi
    #cat $MAILFILE 
done

echo ${THE_LATEST_LECTURE} > ${LATEST_LECTURE_NO_FILE}
