

variable "lifecycle_name" {
  description = "Lifecycle name"
  type        = string
}


variable "repo_name" {
  description = "Github repository name"
  type        = string
}


variable "domain" {
  description = "DNS Domain"
  type        = string
  default     = "sampledomain.com"
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


