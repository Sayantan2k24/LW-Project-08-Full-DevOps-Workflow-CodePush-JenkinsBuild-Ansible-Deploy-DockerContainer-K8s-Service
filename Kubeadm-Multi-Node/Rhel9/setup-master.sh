#!/bin/bash

set -e

# Variables
K8S_VERSION="v1.29"
PROJECT_PATH="prerelease:/main"

# Disable swap
swapoff -a

# Ensure swapoff on reboot
echo "@reboot root /sbin/swapoff -a" >> /etc/crontab

# Install required packages
dnf install -y iproute-tc git

# Load kernel modules
modprobe overlay
modprobe br_netfilter

# Configure kernel modules to load on boot
cat <<EOF > /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

# Configure sysctl settings
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl changes
sysctl --system

# Disable SELinux
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Add Kubernetes repo
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/rpm/repodata/repomd.xml.key
EOF

# Add CRI-O repo
cat <<EOF > /etc/yum.repos.d/cri-o.repo
[cri-o]
name=CRI-O
baseurl=https://pkgs.k8s.io/addons:/cri-o:/${PROJECT_PATH}/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/addons:/cri-o:/${PROJECT_PATH}/rpm/repodata/repomd.xml.key
EOF

# Install Kubernetes components
dnf install -y cri-o kubelet kubeadm kubectl cri-tools

# Enable and start CRI-O and kubelet
systemctl enable --now crio
systemctl enable --now kubelet




# Define variables
MASTER_PRIVATE_IP=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f1)
POD_CIDR="192.168.0.0/16"
NODENAME=$(hostname -s)

# Initialize Kubernetes master
kubeadm init \
--apiserver-advertise-address="${MASTER_PRIVATE_IP}" \
--apiserver-cert-extra-sans="${MASTER_PRIVATE_IP}" \
--pod-network-cidr="${POD_CIDR}" \
--node-name="${NODENAME}" \
--ignore-preflight-errors Swap

# Setup kubeconfig for the current user
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo "✅ Kubernetes common setup completed successfully."

#########################
curl -o calico.yaml https://raw.githubusercontent.com/projectcalico/calico/master/manifests/calico.yaml

####################################
vi calico.yaml
#find the line in the file where Auto-detect is written and make the follwing changes 
# Auto-detect the BGP IP address.
        - name: IP
            value: "autodetect"
        - name: IP_AUTODETECTION_METHOD
            value: "interface=eth0"


kubectl apply -f calico.yaml

kubeadm token create --print-join-command

