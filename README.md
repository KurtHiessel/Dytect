# Dytect
a youtube live stream monitoring tool

## 01. Setup config.yml
- .config.folder: The whole folder where you want to store videos. If going to use Docker, you don't have to change it.
```
Please DO NOT CONTAIN the string of "\/:*?"<>"
```
- .config.interval: Time interval between channels during the monitor loop (in seconds)

## 02. Setup cron
- If you want to run it per five minutes
```
*/5 * * * * /bin/bash /${DIR}/dytect.sh >> /${DIR}/${LOG_NAME}.log 2>&1
```
- IF you want to run it at 23:25
```
25 23 * * * /bin/bash /${DIR}/dytect.sh >> /${DIR}/${LOG_NAME}.log 2>&1
```

## 03. Run via Docker
After setting all the files, you can build a docker image via
```
cd /dytect
docker build --tag dytect:1.0 .
```
Then you may run it via
```
docker run -it -v ${DIR}:/media --name ${NAME} dytect:1.0
```

## 04. Run locally
If you want to run it locally, following dependencies should be fulfilled;
- jq
- yq
- yt-dlp
- ffmpeg
- python3
- chat_downloader (pip3)
If all the packages are installed, you should setup crontab via crontab -e.
```
Be careful to setup $PATH variable first
```
If using Windows, you might use task scheduler instead of cron.

Then make the dytect.sh executable.
```
chmod +x /${DIR}/dytect.sh
```
If you are finally ready to run it, just run it via
```
dytect.sh
```
PROFIT!!
***
Code inspired by sparanoid(https://github.com/sparanoid/live-dl)

For I'm just an amateur, if you can make a better code, please fix it and let me know; for I would like to use yours XD
