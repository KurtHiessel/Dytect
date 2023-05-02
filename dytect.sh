#!/bin/bash
#Dependencies: yt-dlp, ffmpeg, jq, yq
PDIR=$(dirname $0)
LIST_PATH="${PDIR}/config.yml"
DL_PATH="${PDIR}/dytectdl.sh"

LIST=$(yq e -o=j -I=0 '.map[]' "$LIST_PATH")
interval=$(yq '.config.interval' "$LIST_PATH")
echo "$LIST" | while read line; do
    #get the info via yq
    NAME=`echo "$line" | yq e '.name'`
    YID=`echo "$line" | yq e '.id'`
    MOD=`echo "$line" | yq e '.mod'`
    WEBHOOK=`echo "$line" | yq e '.discord'`
    #
    #01. check the process ongoing
    #if true
    NO=`ps aux | grep -v "grep" | grep "dytectdl.sh" | grep "${YID}" | wc -l`
    if [ ${NO} -gt 0 ]; then
        echo "${NAME} already has a process ongoing."
    #if false
    elif [ ${NO} -le 0 ]; then
        echo "Monitoring ${NAME}..."
        bash "${DL_PATH}" $NAME $YID $MOD $WEBHOOK &
    #if error
    else
        echo "An error occurred."
    fi
    #
    #interval before another loop
    echo "Please wait for a while."
    sleep $interval
done

echo "The loop has been completed. Be ready for the next one."
