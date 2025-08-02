#!/bin/bash

# ===========================
# PROJECT: Kidwalks Apparels CI Runner
# ENV: Ubuntu EC2
# USE: CI/CD automation for Stage and Production via GitHub Actions
# ===========================

# List of essential tools and dependencies
packages=(
    curl wget vim git jq unzip tree
    postgresql-client mariadb-client mysql-client
    docker.io docker-compose
)

# Update and upgrade packages
sudo apt update -y && sudo apt upgrade -y

# Install required packages
for package in "${packages[@]}"; do
    echo "Installing $package..."
    sleep 2
    sudo apt install -y "$package"
done
echo "✅ Basic packages installed."

# ===========================
# AWS CLI
# ===========================
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws
echo "✅ AWS CLI installed."

# ===========================
# Docker & Permissions
# ===========================
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
sudo chown root:docker /var/run/docker.sock
sudo chmod 666 /var/run/docker.sock
echo "✅ Docker configured."

# ===========================
# kubectl
# ===========================
curl -LO "https://storage.googleapis.com/kubernetes-release/release/v1.7.0/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/
echo "✅ kubectl installed."

# ===========================
# kubectx + kubens
# ===========================
sudo wget -q https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx
sudo wget -q https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens
sudo chmod +x kubens kubectx
sudo mv kubens kubectx /usr/local/bin/
echo "✅ kubectx & kubens installed."

# ===========================
# Helm
# ===========================
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh && ./get_helm.sh
rm get_helm.sh
echo "✅ Helm installed."

# ===========================
# ArgoCD CLI
# ===========================
ARGO_VER="v2.8.5"
wget "https://github.com/argoproj/argo-cd/releases/download/$ARGO_VER/argocd-linux-amd64" -O argocd
chmod +x argocd && sudo mv argocd /usr/local/bin/
echo "✅ ArgoCD CLI installed."

# ===========================
# Sonar Scanner CLI
# ===========================
SONAR_VER="5.0.1.3006"
wget -q "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_VER}-linux.zip"
unzip "sonar-scanner-cli-${SONAR_VER}-linux.zip"
mv sonar-scanner-${SONAR_VER}-linux sonar-scanner
sudo mv sonar-scanner /var/opt/
sudo ln -sf /var/opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/
rm "sonar-scanner-cli-${SONAR_VER}-linux.zip"
echo "✅ Sonar Scanner installed."

# ===========================
# k9s
# ===========================
curl -sS https://webinstall.dev/k9s | bash
sudo cp -a ~/.local/bin/k9s /usr/local/bin/
echo "✅ k9s installed."

# ===========================
# Vault
# ===========================
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update && sudo apt install vault -y
echo "✅ Vault installed."

# ===========================
# Add CI Users
# ===========================
cat <<EOF > /usr/users.txt
jenkins
ansible
runner
EOF

for user in $(cat /usr/users.txt); do
    sudo id -u "$user" &>/dev/null || sudo useradd -m -s /bin/bash "$user"
    echo "$user:$user" | sudo chpasswd
    sudo usermod -aG sudo,docker "$user"
    echo "$user ALL=(ALL) NOPASSWD: /usr/bin/docker" | sudo tee -a /etc/sudoers
done

echo "✅ CI Users created and added to sudo/docker."

# ===========================
# Set VIM as default editor
# ===========================
sudo update-alternatives --set editor /usr/bin/vim.basic
sudo update-alternatives --set vi /usr/bin/vim.basic

echo "✅ Runner environment for Kidwalks Apparels project is ready."
