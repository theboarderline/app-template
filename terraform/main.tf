
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


resource "google_cloudbuild_trigger" "cloudbuild_trigger" {
  project = local.app_project_id
  name    = "${var.lifecycle_name}-csv-import"

  disabled       = var.disabled
  included_files = [
    "csv-import.yaml",
    "csv/**",
  ]

  github {
    owner = var.github_org
    name  = var.repo_name

    push {
        branch = var.lifecycle_name == "prod" ? "main" : var.lifecycle_name
    }
  }

  filename = "csv-push.yaml"

  substitutions = {
    _BUCKET       = "${var.lifecycle_name}-${var.repo_name}-private"
  }

}

