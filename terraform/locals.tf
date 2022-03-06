locals {

  # TODO: use outputs
  region                = "us-central"
  zone                  = "us-central1-a"
  zones                 = ["us-central1-a"]
  cluster_name          = "central-cluster"
  failover_cluster_name = "east-cluster"

  # region          = data.terraform_remote_state.network[var.lifecycle_name].outputs.region
  # zone            = data.terraform_remote_state.network[var.lifecycle_name].outputs.zone
  # zones           = data.terraform_remote_state.network[var.lifecycle_name].outputs.zones
  # failover_region = data.terraform_remote_state.network[var.lifecycle_name].outputs.failover_region
  # failover_zone   = data.terraform_remote_state.network[var.lifecycle_name].outputs.failover_zone
  # failover_zones  = data.terraform_remote_state.network[var.lifecycle_name].outputs.failover_zones

  # cluster_name          = data.terraform_remote_state.gke.outputs.cluster_name
  # failover_cluster_name = data.terraform_remote_state.gke.outputs.failover_cluster_name

  dns_zone_name = "${var.repo_name}-dns-zone"
}

