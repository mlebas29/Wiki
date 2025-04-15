#!/bin/bash

# 2024 Sep 27 XXXXXXX    Creation
# 2024 Dec 26 XXXXXXX    ajout option -r (certbot renew)

usage() {
  cat <<!
  Usage:

  Options:
    -u : wiki up
    -d : wiki down
    -l : logs
    -p : patch
    -r : renew certificate
    -s : wiki status

    -h : help
    -x : debug
  Examples:
!
}

exit1 () {
  echo "$(basename $0) failed: $*"
  exit 1
}

status () {
  nginx_status="not running"
  seafile_status="not running"
  seafile_pid="$(docker ps -a | grep seafileltd | cut -c1-13)"
  if [ "$seafile_pid" ]; then seafile_status="running"; fi
  if [ "$(cat /run/nginx.pid 2>/dev/null)" ]; then nginx_status="running"; fi
}

#
# Main()
#
WIKI=$HOME/wiki
# Parse command line
while getopts xhudlprs name; do
  case $name in
    u)  opt_u=1;;
    d)  opt_d=1;;
    l)  opt_l=1;;
    p)  opt_p=1;;
    r)  opt_r=1;;
    s)  opt_s=1;;
    x)  set -x;;
    h)  usage; exit 0;;
    ?)  usage; exit 1;;
  esac
done
if [ "$opt_s" ]; then
  #
  # display status
  #
  status
  echo "nginx $nginx_status"
  echo "seafile $seafile_status $seafile_pid"
fi
if [ "$opt_l" ]; then
  #
  # logs
  #
  sudo docker logs -f seafile
fi
# 
#  go to wiki dir
#
cd $WIKI
if [ "$opt_d" ]; then
  #
  # stop Wiki seafile
  #
  if [ ! -f docker-compose.yml ]; then exit1 "$WIKI/docker-compose.yml not found"; fi
  sudo docker-compose down
fi
if [ "$opt_r" ]; then
  #
  # Renew letsencrypt certificate with certbot
  #
  status
  if [ "$nginx_status" = "not running" ]; then
    sudo systemctl start nginx
  fi
  sudo certbot renew
  if [ $? -ne 0 ]; then exit1 "échec certbot"; fi
fi
if [ "$opt_p" ]; then
  #
  # Patch
  #
  if [ ! -f seafile.nginx.conf ]; then exit1 "$WIKI/seafile.nginx.conf not found"; fi
  if [ ! -d /opt/seafile-data/ssl ]; then exit1 "/opt/seafile-data/ssl not found"; fi
  sudo cp seafile.nginx.conf /opt/seafile-data/nginx/conf/seafile.nginx.conf
  sudo cp /etc/letsencrypt/live/labeille.io/fullchain.pem  /opt/seafile-data/ssl/labeille.io.crt
  sudo cp /etc/letsencrypt/live/labeille.io/privkey.pem /opt/seafile-data/ssl/labeille.io.key
fi
if [ "$opt_u" ]; then
  #
  # start Wiki seafile
  #
  if [ ! -f docker-compose.yml ]; then exit1 "$WIKI/docker-compose.yml not found"; fi
  status
  if [ "$nginx_status" = "running" ]; then
    echo "Stop nginx"
    sudo systemctl stop nginx
  fi
  sudo docker-compose up -d
  # Pour s'assurer que le script de certification ssl ne s exécute pas dans le container
  status
  docker exec $seafile_pid mv /root/.acme.sh/acme.sh /root/.acme.sh/acme.sh.ori
  # version manuelle :
  # sudo docker exec -it seafile /bin/bash
  # mv /root/.acme.sh/acme.sh /root/.acme.sh/acme.sh.ori
fi
