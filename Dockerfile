FROM ubuntu:20.04

WORKDIR /app

RUN apt update && \
    apt install -y bash cron vim
RUN apt install -y --no-install-recommends \
    apt-utils curl jq wget python3 python3-pip ffmpeg yt-dlp
RUN wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
RUN chmod a+x /usr/local/bin/yq
RUN pip3 install chat_downloader

COPY ./json_to_txt.py ./json_to_txt.py
COPY ./dytect.sh ./dytect.sh
COPY ./dytectdl.sh ./dytectdl.sh
COPY ./config.yml ./config.yml

RUN chmod a+x ./dytect.sh
RUN chmod a+x ./dytectdl.sh

COPY ./cron /etc/cron.d/cron
RUN chmod 0755 /etc/cron.d/cron
RUN crontab /etc/cron.d/cron
RUN touch /var/log/cron.log

CMD ["cron", "-f"]