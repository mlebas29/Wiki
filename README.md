# Wiki
Mon site de partage privé

Mise en place d’un cloud privé
 - Suivre la procédure d'installation comme indiqué dans https://labeille.net/?p=764

- Installation de la "colle" via wget :

  `install.sh`

- Mise en place du démarrage système :

  `sudo cp $HOME/wiki/wiki.service /etc/systemd/system`
  
  `sudo systemctl daemon-reload`
  
  `sudo systemctl enable wiki`

- Démarrage manuel :
   
  `$HOME/wiki/wiki.sh -up`

- En cas de problème de renouvellement de certificat SSL :

  `sudo systemctl disable snap.certbot.renew.service`
  
  `sudo systemctl disable snap.certbot.renew.timer`
  
  `sudo crontab $HOME/wiki/crontab.txt`


