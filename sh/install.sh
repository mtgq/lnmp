#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin

Download_Mirror='https://soft.vpser.net'
Default_Website_Dir='/www/wwwroot/default'
cur_dir=$(pwd)
Curl_Ver='curl-7.62.0'

Ubuntu_Modify_Source()
{
    OldReleasesURL='https://mirrors.tuna.tsinghua.edu.cn/ubuntu/'
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

echo "Ubuntu_Modify_Source"
Ubuntu_Modify_Source

echo "Create www  user"
groupadd www
useradd -s /sbin/nologin -g www www

echo "Start creating directory..."

mkdir -p ${Default_Website_Dir}
chmod +w ${Default_Website_Dir}
mkdir -p /www/wwwlogs
chmod 777 /www/wwwlogs
chown -R www:www ${Default_Website_Dir}



echo "Complete!"