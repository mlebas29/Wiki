#!/bin/bash

cd 
mkdir wiki
cd wiki
wget https://github.com/mlebas29/Wiki/blob/main/wiki.sh \
     https://github.com/mlebas29/Wiki/blob/main/seafile.nginx.conf \
     https://github.com/mlebas29/Wiki/blob/main/wiki.service \
     https://github.com/mlebas29/Wiki/blob/main/crontab.txt

chmod +x wiki.sh

