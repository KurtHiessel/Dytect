#Import the required packages
import os, io, sys
import json, datetime
from chat_downloader import run
from time import sleep

#UTF-8 setting
sys.stdout = io.TextIOWrapper(sys.stdout.detach(), encoding = 'utf-8')
sys.stderr = io.TextIOWrapper(sys.stderr.detach(), encoding = 'utf-8')

url = sys.argv[1]
folder=sys.argv[2]

run(url=url, output=f'{folder}/chat_original.json', overwrite=False)
if os.path.isfile(f'{folder}/chat_original.json') == True:
    chats = list()
    jopen = open(f'{folder}/chat_original.json', 'r')
    jread = json.load(jopen)
    jopen.close()
    for chat in jread:
        try:
            chats.append((datetime.datetime.fromtimestamp(float(chat['timestamp'])/1000000).strftime('%Y-%m-%d %H:%M:%S'), chat['author']['name'], 'https://www.youtube.com/channel/'+chat['author']['id'], chat['message'], chat['author']['badges'][0]['title']))
        except:
            chats.append((datetime.datetime.fromtimestamp(float(chat['timestamp'])/1000000).strftime('%Y-%m-%d %H:%M:%S'), chat['author']['name'], 'https://www.youtube.com/channel/'+chat['author']['id'], chat['message'], 'Viewer'))
    #
    chat_writer = open(f'{folder}/chat_original.txt', 'w')
    for chat in chats: print(f'{chat[0]}\n{chat[2]} | {chat[4]}\n{chat[1]} : {chat[3]}\n', file=chat_writer)
    chat_writer.close()
    print(f'The chat is now completely extracted', flush=True)
    sleep(2)
else:
    pass
