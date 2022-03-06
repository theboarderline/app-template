
variable "lifecycle_name" {
  description = "Lifecycle name"
  type        = string
}


variable "github_org" {
  description = "Github org name"
  type        = string
}


variable "tf_org" {
  description = "TF Cloud org name"
  type        = string
}


variable "repo_name" {
  description = "Github repository name"
  type        = string
}


variable "domain" {
  description = "DNS Domain"
  type        = string
}


variable "disabled" {
  description = "Whether triggers and DNS/IP should be disabled"
  type        = bool
  default     = false
}


variable "use_helm" {
  description = "Whether triggers should deploy with helm"
  type        = bool
  default     = true
}


variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
  default     = ""
}


variable "gke_project_id" {
  description = "GCP GKE project ID"
  type        = string
  default     = ""
}


variable "db_project_id" {
  description = "GCP database project ID"
  type        = string
  default     = ""
}
