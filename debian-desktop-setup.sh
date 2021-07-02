#!/usr/bin/env bash

#author https://github.com/kkamara
#version 1

YELLOW="\033[1;33m"
GREEN="\033[0;32m"
CYAN="\033[0;36m" 
LIGHTGRAY="\033[0;37m"
RED="\033[0;31m"
NC="\033[0m" # No Color

if [[ "$USER" == "root" ]]; then
    echo -e "${RED}Please run this script as non-root user${NC}"
    exit 1
fi

read -p "Are you using ubuntu os? (Y/n): " isUbuntuOs
isUbuntuOs="${isUbuntuOs,,}" # to lowercase string

installingDocker=1
if [[ "$isUbuntuOs" == "y" ]]; then
    echo -e "${GREEN}We will be installing docker & docker-compose during this script...${NC}"
else
    installingDocker=0
    echo -e "${GREEN}We will skip installing docker & docker-compose during this script...${NC}"
fi

echo -e "${GREEN}Updating, upgradng & autoremoving...${NC}"
sudo apt-get update -y &&
    sudo apt-get upgrade -y &&
    sudo apt-get autoremove -y

echo -e "${GREEN}Downloading package tools...${NC}"
packageTools=(
    wget
    exo-utils
    vlc
    gedit
    openssh-server
    openssh-client
    vim
    neofetch
    rar
    zip
)
for packageTool in "${packageTools[@]}"
    do :
        echo -e "${GREEN}- Downloading $packageTool${NC}"
        sudo apt-get install -y $packageTool
    done

dpkgPackages=()
forParallelProcessing=()

installPath="$HOME/Downloads"
echo -e "${GREEN}Downloading tools to $installPath...${NC}"

echo -e "${GREEN}Downloading composer...${NC}"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/bin/composer

echo -e "${GREEN}Downloading xampp...${NC}"
xamppPath="$installPath/xampp-linux-x64-8.0.7-0-setuper.run"
forParallelProcessing+=("nohup $xamppPath &")
wget https://www.apachefriends.org/xampp-files/8.0.7/xampp-linux-x64-8.0.7-0-setuper.run -P "$installPath"
chmod +x "$xamppPath"

echo -e "${GREEN}Downloading dbeaver...${NC}"
dbeaverPath="$installPath/dbeaver-ce_latest_amd64.deb"
dpkgPackages+=("$dbeaverPath")
wget "https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb" -P "$installPath"
#echo -e "${GREEN}Installing dbeaver...${NC}"
#sudo rm /var/lib/dpkg/lock && sudo rm /var/lib/apt/lists/lock && sudo dpkg -i "$dbeaverPath" && apt install -fy

echo -e "${GREEN}Downloading slack...${NC}"
slackPath="$installPath/slack-desktop-4.16.0-amd64.deb"
dpkgPackages+=("$slackPath")
wget "https://downloads.slack-edge.com/linux_releases/slack-desktop-4.16.0-amd64.deb" -P "$installPath"
#echo -e "${GREEN}Installing slack...${NC}"
#sudo dpkg -i "$slackPath" && apt install -fy

echo -e "${GREEN}Downloading zoom...${NC}"
zoomPath="$installPath/zoom_amd64.deb"
dpkgPackages+=("$zoomPath")
wget https://zoom.us/client/latest/zoom_amd64.deb -P "$installPath"

echo -e "${GREEN}Downloading mega...${NC}"
megaPath="$installPath/megasync_4.4.0-1.1_amd64.deb"
dpkgPackages+=("$megaPath")
wget "https://mega.nz/linux/MEGAsync/xUbuntu_16.04/amd64/megasync_4.4.0-1.1_amd64.deb" -P "$installPath"

echo -e "${GREEN}Installing spotify...${NC}"
sudo snap install spotify

echo -e "${GREEN}Installing nvm...${NC}"
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

echo -e "${GREEN}Downloading golang...${NC}"
wget https://golang.org/dl/go1.16.5.linux-amd64.tar.gz \
    -P "$installPath"
echo -e "${GREEN}Installing golang...${NC}"
tar xvzf go1.16.5.linux-amd64.tar.gz \
    -C "$installPath"
rm "$installPath/go1.16.5.linux-amd64.tar.gz"
sudo mv "$installPath/go /usr"

if [[ "$installingDocker" == 1 ]]; then
    echo -e "${GREEN}Installing docker...${NC}"
    sudo apt-get purge -y docker \
        docker-engine \
        docker.io \
        containerd \
        runc
    
    sudo apt-get update

    sudo apt-get install -y apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | 
        sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    echo -e \
        "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    
    sudo apt-get install -y docker-ce \
        docker-ce-cli \
        containerd.io
    
    echo -e "${GREEN}Installing docker-compose...${NC}"
    sudo rm /usr/local/bin/docker-compose 2>&1

    sudo curl -L \
        "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
    
    sudo chmod +x /usr/local/bin/docker-compose
fi

# print packages requiring manual download
echo -e "${GREEN}To manually download...${NC}"
manualInstallTools=(
    "chrome https://www.google.com/intl/en_uk/chrome/"
    "composer https://getcomposer.org/download/"
    "discord https://discord.com/download"
    "postman https://www.postman.com/downloads/"
    "vscode https://code.visualstudio.com/download"
)
for manualInstallTool in "${manualInstallTools[@]}"
    do :
        echo -e "- $manualInstallTool"
    done

# print sudo run message
echo -e "${GREEN}Run the following as root...${NC}"
printf "${LIGHTGRAY}\tsudo dpkg -i  \\"

for dpkgPackage in "${dpkgPackages[@]}"
	do :
		printf "\n\t\t$dpkgPackage \\"
	done

printf "\n\t&& sudo apt install -fy \\"

for toProcess in "${forParallelProcessing[@]}"
	do :
		printf "\n\t&& $toProcess"
	done

printf "\n${NC}"
