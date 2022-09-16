#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin

# Common function S
##Default website home directory##
Default_Website_Dir='/www/wwwroot/default'

Ubuntu_Modify_Source()
{
    OldReleasesURL='http://mirrors.ustc.edu.cn/ubuntu/'
    CodeName=''
    if grep -Eqi "20.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^20.04'; then
        CodeName='focal'
    elif grep -Eqi "22.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^22.04'; then
        CodeName='jammy'
    fi
    if [ "${CodeName}" != "" ]; then
        \cp /etc/apt/sources.list /etc/apt/sources.list.$(date +"%Y%m%d")
        cat > /etc/apt/sources.list<<EOF
deb ${OldReleasesURL} ${CodeName} main restricted universe multiverse
deb ${OldReleasesURL} ${CodeName}-security main restricted universe multiverse
deb ${OldReleasesURL} ${CodeName}-updates main restricted universe multiverse
deb ${OldReleasesURL} ${CodeName}-proposed main restricted universe multiverse
deb ${OldReleasesURL} ${CodeName}-backports main restricted universe multiverse
deb-src ${OldReleasesURL} ${CodeName} main restricted universe multiverse
deb-src ${OldReleasesURL} ${CodeName}-security main restricted universe multiverse
deb-src ${OldReleasesURL} ${CodeName}-updates main restricted universe multiverse
deb-src ${OldReleasesURL} ${CodeName}-proposed main restricted universe multiverse
deb-src ${OldReleasesURL} ${CodeName}-backports main restricted universe multiverse
EOF
    fi
    apt-get update -y
    echo "change Ubuntu_Modify_Source end"
}

# Common function E


# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

echo "Check_WSL"
if [[ "$(< /proc/sys/kernel/osrelease)" == *[Mm]icrosoft* ]]; then
    echo "running on WSL"
else
    echo "no WSL"
fi

echo "Check_Openssl"
if ! command -v openssl >/dev/null 2>&1; then
    apt-get update -y
    [[ $? -ne 0 ]] && apt-get update --allow-releaseinfo-change -y
    apt-get install -y openssl
fi
openssl version

echo "Setting timezone..."
rm -rf /etc/localtime
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

echo "Ubuntu_Modify_Source"
Ubuntu_Modify_Source


echo "Create www"
groupadd www
useradd -s /sbin/nologin -g www www

echo "Start creating directory..."

mkdir -p ${Default_Website_Dir}
chmod +w ${Default_Website_Dir}
mkdir -p /www/wwwlogs
chmod 777 /www/wwwlogs
chown -R www:www ${Default_Website_Dir}


echo "Install Docker? (y/n) "
read allow_rewrite
if [ "${allow_rewrite}" == "y" ]; then
    echo "install docker..."
    apt-get remove docker docker-engine docker.io containerd runc

    apt-get install ca-certificates curl gnupg lsb-release

    mkdir -p /etc/apt/keyrings
    curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt-get update -y
    apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

    systemctl start docker
    docker run hello-world

    sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://9gqe7epy.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
    echo "Install Docker Compose"
    curl -L https://get.daocloud.io/docker/compose/releases/download/v2.11.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    echo "docker images..."
fi


echo "Install Complete!"

















