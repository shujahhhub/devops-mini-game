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
