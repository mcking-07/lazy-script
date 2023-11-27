#!/bin/bash

set -e

# check if root
if [[ $EUID -ne 0 ]]; then
  echo -e "error: you must be a root user to run this script. \nplease run 'sudo $0'" >&2
  exit 1
fi

# update system packages
apt update && apt upgrade -y

# disable snapd services
systemctl disable snapd.service
systemctl disable snapd.socket
systemctl disable snapd.seeded.service

# remove snap packages
snap list | awk '{print $1}' > ./snap-packages.txt
tac ./snap-packages.txt | xargs snap remove

# remove snapd files and directories
rm -rf /var/cache/snapd/
apt autoremove --purge snapd
rm -rf ~/snap ./snap-packages.txt

# update system packages
apt update && apt upgrade -y

# install media codecs
apt install ubuntu-restricted-extras -y

# install cli tools and applications
apt install wget git curl emacs nano vim neovim unzip -y

# install common dev-tools and dependencies
apt install apt-transport-https build-essential ca-certificates gnupg gnupg-agent gcc g++ cmake lsb-release nodejs npm software-properties-common python3 apache2 nginx -y

# install more cli tools and applications
apt install bat cmatrix exa figlet fortune-mod lolcat neofetch parallel speedtest-cli trash-cli -y

# download deb-packages for some common applications
mkdir -p deb-packages/ && cd deb-packages/
wget 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' -O code.deb
wget 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb' -O google-chrome.deb
wget 'https://github.com/dandavison/delta/releases/download/0.8.3/git-delta_0.8.3_amd64.deb' -O git-delta.deb
wget 'https://releases.hyper.is/download/deb' -O hyper-term.deb
wget 'https://updates.getmailspring.com/download?platform=linuxDeb' -O mailspring.deb
wget 'https://downloads.slack-edge.com/linux_releases/slack-desktop-4.20.0-amd64.deb' -O slack.deb

# install downloaded deb-packages
dpkg -i code.deb google-chrome.deb git-delta.deb hyper-term.deb mailspring.deb slack.deb -y

# remove downloaded deb-packages
cd ../ && rm -rf ./deb-packages

# download zip files for some more applications
mkdir -p zips && cd zips/
wget 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -O aws-cli.zip

# unzip and install downloaded zips
unzip aws-cli.zip
bash ./aws/install

# remove downloaded zips
cd ../ && rm -rf ./zips

# add common repositories and keyrings
apt-add-repository ppa:ansible/ansible
mkdir -p /etc/apt/keyrings
curl -fsSL 'https://pkg.cloudflare.com/cloudflare-main.gpg' | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/cloudflare-main.gpg] 'https://pkg.cloudflare.com/cloudflared' $(lsb_release -cs)" | tee /etc/apt/sources.list.d/cloudflared.list > /dev/null
curl -fsSL 'https://download.docker.com/linux/ubuntu/gpg' | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] 'https://download.docker.com/linux/ubuntu' $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# update system packages
apt update && apt upgrade -y

# install more dev-tools from added repositories
apt install ansible cloudflared docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

# add user group for docker
groupadd docker
usermod -aG docker $USER

# install nvm
curl 'https://raw.githubusercontent.com/creationix/nvm/master/install.sh' | bash

# install common gnome-tools
apt install gnome-tweaks gnome-shell-extension-manager chrome-gnome-shell -y
apt install --install-suggests gnome-software -y && flatpak remote-add --if-not-exists flathub 'https://flathub.org/repo/flathub.flatpakrepo'

# install gnome-extensions
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
gnome-extensions enable Hide_Activities@shay.shayel.org
gnome-extensions enable openweather-extension@jenslody.de
gnome-extensions enable search-light@icedman.github.com
gnome-extensions enable rocketbar@chepkun.github.com
gnome-extensions enable openweather-extension@jenslody.d
gnome-extensions enable clipboard-history@alexsaveau.dev
gnome-extensions enable burn-my-windows@schneegans.github.com

# download theme -- nord
git clone 'https://github.com/EliverLara/Nordic.git' /usr/share/themes/nordify

# install cursor -- nordzy
git clone 'https://github.com/alvatip/Nordzy-cursors' nordzy-cursors
bash ./nordzy-cursors/install.sh

# download fonts
apt install fonts-font-awesome
wget 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip' -O fira-code.zip
wget 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip' -O meslo.zip
wget 'https://github.com/todylu/monaco.ttf/raw/master/monaco.ttf' -O Monaco.ttf

# install fonts
unzip meslo.zip -d /usr/share/fonts && unzip fira-code.zip -d /usr/share/fonts
mv Monaco.ttf /usr/share/fonts
fc-cache -vf

# remove unwanted files and directories
rm -rf fira-code.zip meslo.zip nordzy-cursors

# print banger message on completion
echo -e "\n\n\e[1;96m---------------------------------------------------"
echo -e "|   🎉 Congratulations! Your System Is Epic! 🎉   |"
echo -e "---------------------------------------------------\e[0m\n"
