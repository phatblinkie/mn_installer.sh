#!/bin/bash

echo "This is for premium verion 1.8.1.2 hulk release"
sleep 5

SECTION_SEPARATOR="========================================="
ENV_PATH=/etc/pirlnode-env
DOWNLOAD_LINK_PREMIUM="https://git.pirl.io/community/pirl/uploads/8f3823838355d18b5d6d9b16129c2499/pirl-linux-amd64-v5-masternode-premium-hulk"
DOWNLOAD_LINK_MARLIN="https://git.pirl.io/community/pirl/uploads/f991222e04b2525cfb4a94a078f7247b/marlin-v5-masternode-premium-hulk"
PREMIUM_PATH=/usr/bin/pirl
MARLIN_PATH=/usr/bin/marlin

#fix previous paths
#if the file is found, then it was previously run, change it
if [ -f /usr/local/bin/pirl-premium-core ] 
  then
    systemctl stop pirlnode
    systemctl disable pirlnode
    sleep 2
    rm -f /usr/local/bin/pirl-premium-core 
    rm -f /etc/systemd/system/pirlnode.service 
    systemctl daemon-reload
 fi
 #if the file is found, then it was previously run, change it
 if [ -f /usr/local/bin/pirl-premium-marlin ] 
  then
    systemctl stop pirlmarlin
    systemctl disable pirlmarlin
    sleep 2
    rm -f /usr/local/bin/pirl-premium-marlin
    rm -f /etc/systemd/system/pirlmarlin.service
    systemctl daemon-reload
 fi 



echo $SECTION_SEPARATOR
echo

## https://poseidon.pirl.io/accounts/masternodes-list-private/
MASTERNODE=""
echo "Copy/Paste in the MN token.  It can be found at https://poseidon.pirl.io/accounts/masternodes-list-private/"
echo "Or leave it blank if you already have it written in $ENV_PATH and want no change"
echo
read -p 'Enter MN token:' MASTERNODE
echo

if [[ -f $ENV_PATH && "$MASTERNODE" = "" ]]; then
	echo "Leaving MN token as is"
	echo
 else
 	if [[ ! -f $ENV_PATH && "$MASTERNODE" = "" ]]; then
		echo "$ENV_PATH file for tokens doesn't exist"
	fi
	echo
 	rm -f $ENV_PATH
	while [ "$MASTERNODE" = "" ]; do
		echo "Copy/Paste in the MN token.  It can be found at https://poseidon.pirl.io/accounts/masternodes-list-private/"
		read -p 'Enter MN token:' MASTERNODE
		echo
	done
 fi

echo $SECTION_SEPARATOR
echo

## https://poseidon.pirl.io/accounts/settings/
TOKEN=""
if [ "$MASTERNODE" != "" ]; then
	while [ "$TOKEN" = "" ]; do
	  echo "Copy/Paste in your POSEIDON account's token.  It can be found at https://poseidon.pirl.io/accounts/settings/"
	  echo
	  read -p 'Enter TOKEN:' TOKEN
	  echo
	done
 else
	echo "Leaving POSEIDON token as is"
 fi
echo

echo $SECTION_SEPARATOR
echo


# download wget before pirl installation

if [ ! -f /usr/bin/wget ] ; then
	echo "Installing wget..."
	apt install wget -y >/dev/null 2>/dev/null
	apt-get install wget -y >/dev/null 2>/dev/null
	yum install -y wget >/dev/null 2>/dev/null
fi

############# grab the node binary and chmod ############################
###the chain will end up being stored on this users home dir, at /home/username/.pirl/
###or /root/.pirl

##make sure its not running if for reason the service is already there, do clean up incase it was run again  for some reason
echo "Stopping pirl, if it is running."
systemctl stop pirl 2>/dev/null 1>/dev/null
sleep 2
if [ -e $PREMIUM_PATH ]; then
  echo "Cleaning up previous PIRL installation."
  rm -f $PREMIUM_PATH 2>/dev/null
fi
#get pirl node
echo "downloading latest PIRL Masternode"
wget -O $PREMIUM_PATH $DOWNLOAD_LINK_PREMIUM
downloadresult=$?
chmod 0755 $PREMIUM_PATH
chmodresult=$?

#double check download and perms
if [ "$downloadresult" != "0" ] || [ "$chmodresult" != "0" ]; then
  echo "error happened downloading the node from"
  echo $DOWNLOAD_LINK_PREMIUM
  echo "or trying to chmod it to 0755 at location"
  echo $PREMIUM_PATH
  exit 6
fi

echo $SECTION_SEPARATOR
echo

############# grab the marlin-node binary and chmod ############################
###the chain will end up being stored on this users home dir, at /home/username/.pirl/

##make sure its not running if for reason the service is already there, do clean up incase it was run again  for some reason
echo "Stopping marlin, if it is running."
systemctl stop marlin 2>/dev/null 1>/dev/null
sleep 2
if [ -e $MARLIN_PATH ]; then
  echo "Cleaning up previous PIRL installation."
  rm -f $MARLIN_PATH 2>/dev/null
fi
#get pirl-marlin node
echo "downloading latest PIRL Marlin"
wget -O $MARLIN_PATH $DOWNLOAD_LINK_MARLIN
downloadresult=$?
chmod 0755 $MARLIN_PATH
chmodresult=$?

#double check download and perms
if [ "$downloadresult" != "0" ] || [ "$chmodresult" != "0" ]; then
  echo "error happened downloading the node from"
  echo $DOWNLOAD_LINK_MARLIN
  echo "or trying to chmod it to 0755 at location"
  echo $MARLIN_PATH
  exit 6
fi

echo $SECTION_SEPARATOR
echo

############ populate files for systemd service #########
echo "Create pirl-node systemd unit file, install, and start."
echo "[Unit]
Description=Pirl Master Node
After=network-online.target
Wants=network-online.target

[Service]
;EnvironmentFile=$ENV_PATH
Environment=MASTERNODE=$MASTERNODE
Environment=TOKEN=$TOKEN

Type=simple
User=root
Group=root
RestartSec=30s
ExecStart=$PREMIUM_PATH --ws --wsorigins=* --wsaddr=0.0.0.0 --rpc --rpcaddr=0.0.0.0 --rpccorsdomain="*"
Restart=always
ExecStartPre=/bin/sleep 5
RemainAfterExit=no

[Install]
WantedBy=multi-user.target
">/lib/systemd/system/pirl.service

#tokens are now in the systemd files
#if [[ -f $ENV_PATH ]]; then
#	echo "token file already present, skipping"
#else
#echo "MASTERNODE=\"$MASTERNODE\"
#TOKEN=\"$TOKEN\"">$ENV_PATH
#echo "Successfully created $ENV_PATH with new tokens"
#fi

###reload in case it was there before, and now could be changed
systemctl daemon-reload

####enable the node
systemctl enable pirlnode

###start the node
systemctl restart pirlnode


############ populate files for systemd-marlin service #########
echo "Create pirl-marlin systemd unit file, install, and start."
echo "[Unit]
Description=Pirl Client -- marlin content service
After=network.target pirl.service
Wants=network.target pirl.service

[Service]
;EnvironmentFile=$ENV_PATH
Environment=MASTERNODE=$MASTERNODE
Environment=TOKEN=$TOKEN

Type=simple
User=root
Group=root
RestartSec=30s
ExecStartPre=/bin/sleep 5
ExecStart=$MARLIN_PATH daemon
Restart=always

[Install]
WantedBy=default.target
">/lib/systemd/system/marlin.service

if [[ ! -d $homedir/.marlin/ || ! -f $homedir/.marlin/config ]]; then
	rm -rf $homedir/.marlin/
	echo "Wait 5 seconds for pirlnode to run before initializing marlin"
	echo -ne ".\r"
	sleep 1
	echo -ne "..\r"
	sleep 1
	echo -ne "...\r"
	sleep 1
	echo -ne "....\r"
	sleep 1
	echo -ne ".....\r"
	sleep 1
	echo -ne "\r\033[K"
	su -c "$MARLIN_PATH init 1>/dev/null" $RUNAS_USER -s /bin/bash
	chown -R $RUNAS_USER:$RUNAS_USER $homedir/.marlin/
	
	if [ -f $homedir/.marlin/config ]; then
		echo "Pirl marlin successfully initialized"
 	else
  		echo "Something went wrong with initializing marlin folder"
		echo "Please run '$MARLIN_PATH init' manually after installation"
	fi
fi

###reload in case it was there before, and now could be changed
systemctl daemon-reload

####enable the node
systemctl enable pirlmarlin

###start the node
systemctl restart pirlmarlin


echo $SECTION_SEPARATOR
echo

#ask if wants to install firewall and change ssh
ASK_FIREWALL="y"
while [ "$ASK_FIREWALL" = "y" ]; do
  read -p "Would you like to install and configure firewall and change SSH settings? (y/N): " SET_FIREWALL
  if [[ "$SET_FIREWALL" = "y" || "$SET_FIREWALL" = "Y" ]]; then
  	SET_FIREWALL="y"
  	ASK_FIREWALL="n"
  else
    if [[ "$SET_FIREWALL" = "n" || "$SET_FIREWALL" = "N" || "$SET_FIREWALL" = "" ]]; then
    	SET_FIREWALL="n"
	ASK_FIREWALL="n"
    fi
  fi
  echo
done

if [ "$SET_FIREWALL" = "y" ]; then
   bash ./firewall_installer.sh
fi

echo "All done!"
echo
echo "Commands you can run now:"
echo "Check PIRL-node status with: 'systemctl status pirl'"
echo "Check PIRL-marlin status with: 'systemctl status marlin'"
echo "Watch PIRL-node system logs with: 'journalctl -f -u pirl'"
echo "Watch PIRL-marlin system logs with: 'journalctl -f -u marlin'"
if [ "$SET_FIREWALL" = "y" ]; then
   echo "Check firewall status with: 'ufw status'"
fi

exit 0

