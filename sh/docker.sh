
groupadd docker
# 添加你想用普通用户权限的用户名到 docker 用户组
usermod -aG docker $USER
usermod -aG docker www

echo "install docker..."
apt-get remove docker docker-engine docker.io containerd runc

apt-get install -y ca-certificates curl gnupg lsb-release

mkdir -p /etc/apt/keyrings
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

service docker start

sudo mkdir -p /etc/docker

sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://9gqe7epy.mirror.aliyuncs.com"]
}
EOF

sudo service docker restart

echo "Install Docker Compose"
curl -L https://get.daocloud.io/docker/compose/releases/download/v2.11.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose


docker-compose --version

echo "Complete!"