# UPDATE: for centos users, you can now use the pirl repository. http://repo.pirl.io
Added a script to help users install with the repository, it will overwrite the same file locations as this normal installer, but make future updates as easy as running a simple 'yum update' command.
to use this, run  	
## To run this script
Clone this git repository: `git clone https://github.com/phatblinkie/mn_installer.git`
Change into the newly created directory: `cd mn_installer`
Run this script via the command: `sudo ./install_PIRL_rpms.sh`

# mn_installer.sh
This script will install a Premium or Content masternode https://chaindata.pirl.network/1-9-12-lion/ for PIRL on stock Ubuntu, or centos.

## This script will do the following

1. Ask user to enter his MN token and Poseidon token.
2. If a user already had Premium node installation and only wants to upgrade binaries tokens will not be changed.
3. Optionally make a user, and home directory, to run the PIRL service.
4. Download pirl premium masternode binary and set permissions on it.
5. Download pirl premium marlin binary and set permissions on it.
6. Setup a configuration file named pirlnode.conf under /etc/pirl/ for the masternode tokens.
7. Check out if pirl marlin was initialized before. If not will initialize it.
8. Setup a systemd service named pirl and marlin, enable it, and start it.
9. If user wants to change SSH port, install firewall and upgrade system, runs firewall.sh module.

## firewall.sh module will do the following
1. Upgrades system if user allows.
2. Install the ufw firewall and open needed ports. (will be updated soon to firewalld instead to align more with one click installer)
3. Optionally update the SSH daemon to run on a non-standard port of your choice.

## To run this script
1. Install git: `sudo apt install git`
2. Clone this git repository: `git clone https://github.com/phatblinkie/mn_installer.git`
3. Change into the newly created directory: `cd mn_installer`
4. Run this script via the command: `sudo ./pirl_masternode_installer.sh`

