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

echo "✅ Kubernetes common setup completed successfully."

# copy the command
kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash <hash>

# Example
# kubeadm join 172.31.84.118:6443 --token 7b477r.fbnsaxafe77nzlik \
#         --discovery-token-ca-cert-hash sha256:87a91c9c8bcf70510576bb76f13d972a7edb7249980a800ed4c3d9b658af05b7