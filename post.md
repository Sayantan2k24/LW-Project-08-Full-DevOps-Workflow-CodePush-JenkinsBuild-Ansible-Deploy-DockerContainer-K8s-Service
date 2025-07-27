🚀 **Project 08 - Full DevOps CI/CD Pipeline on Kubernetes | Jenkins | Ansible | Docker | AWS EC2**

Just wrapped up a hands-on project where I built a **self-managed, full-scale CI/CD pipeline from scratch** — running entirely on AWS EC2 using **Kubernetes, Docker, Jenkins, and Ansible**. No managed services, no shortcuts — just raw infrastructure and open-source power. 💪

🔧 **What I built:**

* A **multi-node K8s cluster** (kubeadm, Calico CNI) across 2 EC2 instances (RHEL 9)
* **Dockerized Jenkins server inside Kubernetes**, with persistent storage + dynamic agent pods
* **Ansible running inside a pod**, auto-triggered from Jenkins to deploy apps to K8s
* A **Flask-based app**, containerized and deployed via Ansible playbooks
* Full CI/CD pipeline triggered on **GitHub commits** via SCM polling

📌 **Key Highlights:**

* Jenkins dynamically spawns a pod to **build & push Docker images**
* **Ansible playbooks** (from ConfigMap) handle parameterized deployments inside K8s
* RBAC + Namespaces + Secrets handled securely for Jenkins & Ansible
* Used **CRI-O** runtime with native tooling; everything runs inside K8s pods
* Rolling updates via Kubernetes Deployments ensure **zero-downtime rollouts**

💡 Bonus: Used `ansible-galaxy` and `kubernetes.core` modules for direct K8s resource management without kubectl.

🧱 Stack:

* AWS EC2 (RHEL 9)
* kubeadm + CRI-O + Calico
* Jenkins inside K8s (NodePort: 30080)
* Ansible pod with SSH, kubectl & service account tokens
* Docker Hub for image storage
* App exposed on NodePort: 30500

🔗 GitHub Repo:
https://github.com/Sayantan2k24/LW-Project-08-Full-DevOps-Workflow-CodePush-JenkinsBuild-Ansible-Deploy-DockerContainer-K8s-Service.git

---
Thanks to Vimal Daga sir for whatever I know as those knowledge and troubleshooting skills really helped me here connecting the dots.

💬 Always open to feedback, suggestions, or collaborations on similar DevOps or platform engineering projects!

#DevOps #Kubernetes #Jenkins #Ansible #Docker #CICD #AWS #OpenSource #SelfManaged #InfrastructureAsCode #Kubeadm #Linux #Automation #CloudNative

---

