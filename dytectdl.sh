#!/bin/bash
#get args
NAME=$1
YID=$2
MOD=$3
WEBHOOK=$4
PDIR=$(dirname $0)
PYLOC="${PDIR}/json_to_txt.py"
LIST_PATH="${PDIR}/config.yml"

#read dir from config.yml
DIR=$(yq '.config.folder' $LIST_PATH)

#print metadata via yt-dlp; idea from live-dl
METADATA_RAW=`yt-dlp --ignore-config --no-playlist --playlist-items 0 --no-warnings \
        --dump-json --referer 'https://www.youtube.com/feed/subscriptions' \
        "https://www.youtube.com/channel/${YID}/live" 2> /dev/null`

#start monitoring
if [ ! -z "$METADATA_RAW" ]; then
    #to make json parsable
    METADATA=`echo $METADATA_RAW | jq -R '.' | jq -s '.' | jq -r 'join("")'`

    #get video id and uploader
    VID=`echo $METADATA | jq -r '.id'`
    UPLOADER=`echo $METADATA | jq -r '.uploader'`
    UPLOAD_DATE=`echo $METADATA | jq -r '.upload_date'`

    echo "${NAME}'s streaming in online. Sending the discord webhook.."
    #send discord webhook message
    curl -H "Content-Type: application/json" \
    --user-agent "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:29.0) Gecko/20120101 Firefox/29.0" \
    -d "{\"content\": \"${UPLOADER}'s live is now on'.\nhttps://youtu.be/${VID}\"}" \
    $WEBHOOK

    #print the message
    echo "Completed sending webhook message. Trying to archive ${NAME}'s live stream.."

    #archiving live stream
    #mod: total
    if [ "$MOD" == "total" ]; then
        
        #make a folder
        FOLDER="${DIR}/${NAME}/${UPLOAD_DATE}_${VID}"
        mkdir -p "${FOLDER}"
        #recording the live stream
        yt-dlp -q --live-from-start --write-description --write-thumbnail --write-info-json \
        "https://youtu.be/${VID}" -o "${FOLDER}/%(title)s.%(ext)s" &
        python3 "${PYLOC}" "https://youtu.be/${VID}" $FOLDER > /dev/null 2>&1 &
        #
        WORK_PID=`jobs -l | awk '{print $2}'`
        wait $WORK_PID

        #convert files after the record
        #webp to png
        echo "${NAME}의 라이브 스트리밍 녹화가 성공적으로 완료되었습니다. 각종 파일 변환을 변환합니다."
        for inputwebp in "$FOLDER"/*.webp; do
            inputwebpfolder="$( dirname "$inputwebp" )"
            ffmpeg -y -i "$inputwebp" "${inputwebpfolder}/cover.png"
            rm "$inputwebp"
        done
        #~~.jpg to cover.jpg
        for inputjpg in "$FOLDER"/*.jpg; do
            inputjpgfolder="$( dirname "$inputjpg" )"
            mv "$inputjpg" "${inputjpgfolder}/cover.jpg"
        done
        #description to txt
        for inputtext in "$FOLDER/"*.description; do
            inputtextfolder="$( dirname "$inputtext" )"
            mv "$inputtext" "${inputtextfolder}/설명.txt"
        done
        #
        echo "${NAME}의 라이브 스트리밍 백업 작업이 완전히 종료되었습니다. 감사합니다."

    #mod: comment
    elif [ "$MOD" == "comment" ]; then
        
        #make a folder
        FOLDER="${DIR}/${NAME}/${UPLOAD_DATE}_${VID}"
        mkdir -p "${FOLDER}"
        #write live chats
        python3 "${PYLOC}" "https://youtu.be/${VID}" $FOLDER > /dev/null 2>&1 &
        #
        WORK_PID=`jobs -l | awk '{print $2}'`
        wait $WORK_PID

    #error message
    else
        echo "Unknown mod detected. Please check ${NAME}'s mod in config.yml."
    fi

else
    echo "Ongoing ${NAME}'s live stream wasn't found'. Skipping to the next channel.."
fi

exit