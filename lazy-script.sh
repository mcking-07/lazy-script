#!/bin/bash

# set exit on error
set -e

# check if root
[[ $EUID -ne 0 ]] && { echo -e "error: you must be a root user to run this script. \nplease run 'sudo $0'"; exit 1; }

# set target user for application specific permissions
TARGET_USER=$(ls /home/)

# update system packages
apt update && apt upgrade -fy

# update system packages
apt update && apt upgrade -fy

# install media codecs
apt install ubuntu-restricted-extras -fy

# install cli tools and applications
apt install wget git curl emacs nano vim neovim unzip -fy

# install common dev-tools and dependencies
apt install apt-transport-https build-essential ca-certificates fonts-font-awesome gnupg gnupg-agent gcc g++ cmake libsecret-1-dev lsb-release nodejs npm software-properties-common python3 apache2 nginx -fy

# install more cli tools and applications
apt install bat cmatrix exa figlet fortune-mod lolcat neofetch parallel speedtest-cli trash-cli -fy

# declate deb-packages
declare -a deb_packages=(
  'code             - https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'
  'cloudflared      - https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb'
  'google-chrome    - https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'
  'git-delta        - https://github.com/dandavison/delta/releases/download/0.8.3/git-delta_0.8.3_amd64.deb'
  'hyper-term       - https://releases.hyper.is/download/deb'
  'mailspring       - https://updates.getmailspring.com/download?platform=linuxDeb'
  'slack            - https://downloads.slack-edge.com/releases/linux/4.35.126/prod/x64/slack-desktop-4.35.126-amd64.deb'
)

# create deb-packages directory
mkdir -p deb-packages/ && cd deb-packages/

# download and install deb-packages
for pkg in "${deb_packages[@]}"; do read -r name _ url <<< "$pkg"; wget -O "$name.deb" "$url"; done
dpkg -i *.deb
apt install -fy

# clean up deb-packages directory
cd ../ && rm -rf ./deb-packages

# decalre zip-files
declare -a zip_files=(
  'aws-cli          - https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip'
)

# create zip-files directory
mkdir -p zips && cd zips/

# download and install zip-files
for file in "${zip_files[@]}"; do read -r name _ url <<< "$file"; wget -O "$name.zip" "$url"; done
unzip *.zip
bash ./aws/install

# clean up zip-files directory
cd ../ && rm -rf ./zips

# add repositories and keyrings
apt-add-repository ppa:ansible/ansible
mkdir -p /etc/apt/keyrings
curl -fsSL 'https://download.docker.com/linux/ubuntu/gpg' | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# update system packages and install additional dev-tools
apt update && apt upgrade -fy
apt install ansible docker-ce docker-ce-cli containerd.io docker-compose-plugin -fy

# add user group for docker
grep -q '^docker:' /etc/group || groupadd docker
# usermod -aG docker $USER
usermod -aG docker $TARGET_USER

# install nvm
curl 'https://raw.githubusercontent.com/creationix/nvm/master/install.sh' | sudo -u $TARGET_USER bash

# install common gnome-tools
apt install gnome-tweaks gnome-shell-extension-manager chrome-gnome-shell -fy
apt install --install-suggests gnome-software -fy && flatpak remote-add --if-not-exists flathub 'https://flathub.org/repo/flathub.flatpakrepo'

# create list of snap packages
snap_packages=$(snap list | awk '$1 != "Name" && $1 != "snapd" {print $1}' | tac)
snap_packages+=" snapd"

# remove snap packages
for pkg in $snap_packages; do snap remove "$pkg"; done

# disable snapd services
systemctl disable snapd.service snapd.socket snapd.seeded.service

# remove snapd files and directories
rm -rf /var/cache/snapd/
apt autoremove --purge snapd
rm -rf ~/snap

# declare gnome-extensions
declare -a gnome_extensions=(
  'user-theme@gnome-shell-extensions.gcampax.github.com'
  'Hide_Activities@shay.shayel.org'
  'openweather-extension@jenslody.de'
  'search-light@icedman.github.com'
  'rocketbar@chepkun.github.com'
  'openweather-extension@jenslody.d'
  'clipboard-history@alexsaveau.dev'
  'burn-my-windows@schneegans.github.com'
)

# install and enable gnome-extensions -- temp workaround cause couldn't figure out cli download and install
for extension in "${gnome_extensions[@]}"; do echo "$extension" >> "/home/$TARGET_USER/extentions.txt"; done

# download and install theme -- nord
git clone 'https://github.com/EliverLara/Nordic.git' /usr/share/themes/nordify

# download and install cursor -- nordzy
git clone 'https://github.com/alvatip/Nordzy-cursors' nordzy-cursors
bash ./nordzy-cursors/install.sh

# declare fonts
declare -a fonts=(
  'fira-code.zip    - https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip'
  'meslo.zip        - https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip'
  'Monaco.ttf       - https://github.com/todylu/monaco.ttf/raw/master/monaco.ttf'
)

# download and install fonts
for font in "${fonts[@]}"; do read -r name _ url <<< "$font"; wget -O "$name" "$url"; done
unzip meslo.zip -d /usr/share/fonts && unzip fira-code.zip -d /usr/share/fonts
mv Monaco.ttf /usr/share/fonts

# update font cache
fc-cache -vf

# clean up font files and cursors directory
rm -rf fira-code.zip meslo.zip nordzy-cursors

# print banger message on completion
echo -e "\n\n\e[1;96m---------------------------------------------------"
echo -e "|   🎉 Congratulations! Your System Is Epic! 🎉   |"
echo -e "---------------------------------------------------\e[0m\n"
