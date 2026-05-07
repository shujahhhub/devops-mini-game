# 🚀 Highly Available Kubernetes Web App (IaC Deployment)

A containerized web application deployed to a local Kubernetes cluster (Minikube) using Terraform. This project demonstrates core enterprise DevOps principles, specifically focusing on Infrastructure as Code (IaC), high availability, and automated load management.

## 🛠️ Tech Stack
* **Application:** Python 3.12, Flask
* **Containerization:** Docker
* **Orchestration:** Kubernetes (Minikube)
* **Infrastructure as Code (IaC):** Terraform

## 🏗️ Architecture & Cloud Features
Rather than manually applying Kubernetes manifests, this entire infrastructure is provisioned dynamically via a single Terraform blueprint (`main.tf`). 

* **Horizontal Pod Autoscaler (HPA):** Configured to monitor container CPU utilization. If average CPU exceeds 50%, Kubernetes automatically scales the deployment from 1 up to 5 replicas to handle the traffic spike.
* **Load Balancing:** Utilizes a Kubernetes Service to distribute incoming traffic seamlessly across all active, healthy pods.
* **Pod Identification:** The web UI dynamically displays the exact underlying Pod ID serving the request, providing visual proof of load balancing during scale-out events.

## ⚙️ How to Deploy Locally

**Prerequisites:** Docker, Minikube, Terraform, and `kubectl` installed.

Prep the Kubernetes Cluster:
Ensure your local cluster is running and the metrics server (required for HPA) is active.

Bash
minikube start
minikube addons enable metrics-server

3. Build and Inject the Container:
Build the Docker image and load it directly into Minikube's local cache.

Bash
docker build -t devops-ha-game:latest .
minikube image load devops-ha-game:latest
4. Deploy via Terraform:
Use Infrastructure as Code to provision the deployment, service, and autoscaler.

Bash
terraform init
terraform apply -auto-approve
5. Access the Application:

Bash
minikube service devops-game-service --url
🔥 Stress Testing the Auto-Scaler
To prove the high availability architecture works, you can simulate a massive traffic spike using a temporary busybox container.

1. Open a terminal and watch the Auto-Scaler:

Bash
kubectl get hpa -w
2. Open a second terminal and launch the attack:

Bash
kubectl run -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://devops-game-service; done"
Watch as the CPU metrics spike and Kubernetes automatically scales the application to 5 replicas to prevent crashing. Refresh the web browser to see the Load Balancer shift traffic across the newly provisioned pods!

