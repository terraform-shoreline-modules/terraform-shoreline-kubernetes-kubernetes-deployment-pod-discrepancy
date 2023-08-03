terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "kubernetes_deployment_pod_discrepancy" {
  source    = "./modules/kubernetes_deployment_pod_discrepancy"

  providers = {
    shoreline = shoreline
  }
}