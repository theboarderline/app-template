
module "app" {
  source = "app.terraform.io/lakegames/app/google"

  lifecycle_name = var.lifecycle_name
  disabled       = var.disabled
  domain         = var.domain
  repo_name      = var.repo_name

  gke_project_id = local.gke_project_id
  app_project_id = local.app_project_id
  dns_zone_name  = local.dns_zone_name

  use_helm = var.use_helm
}

