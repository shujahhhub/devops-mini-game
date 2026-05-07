# 1. THE PROVIDER: Tell Terraform how to talk to Minikube
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

# 2. THE DEPLOYMENT: Tell Kubernetes to run your Docker Image
resource "kubernetes_deployment" "game_deployment" {
  metadata {
    name = "devops-game"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "devops-game"
      }
    }
    template {
      metadata {
        labels = {
          app = "devops-game"
        }
      }
      spec {
        container {
          name              = "game-container"
          image             = "devops-ha-game:latest"
          image_pull_policy = "Never" # Forces Minikube to use the local image we just injected
          
          port {
            container_port = 5000
          }

          # CRITICAL FOR AUTOSCALING: You must define how much CPU the app uses
          resources {
            limits = {
              cpu    = "50m"  # Max half of 1/10th of a CPU core
              memory = "128Mi"
            }
            requests = {
              cpu    = "20m"
              memory = "64Mi"
            }
          }
        }
      }
    }
  }
}

# 3. THE SERVICE: Create a Load Balancer to expose the game to your browser
resource "kubernetes_service" "game_service" {
  metadata {
    name = "devops-game-service"
  }
  spec {
    selector = {
      app = "devops-game"
    }
    port {
      port        = 80
      target_port = 5000
      node_port   = 30000 # The static port we will use to access the game
    }
    type = "NodePort"
  }
}

# 4. THE AUTO-SCALER: Tell Kubernetes when to clone the server
resource "kubernetes_horizontal_pod_autoscaler_v2" "game_hpa" {
  metadata {
    name = "devops-game-hpa"
  }
  spec {
    min_replicas = 1
    max_replicas = 5

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.game_deployment.metadata[0].name
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 50 # If CPU hits 50%, spin up a new server!
        }
      }
    }
  }
}