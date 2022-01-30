# Terraform Workspace: Application

This is the Terraform workspace directory for deploying application resources like Cloudbuild Triggers, Artifact Registries, and DNS resources.

<img alt="Terraform" src="https://www.terraform.io/assets/images/logo-text-8c3ba8a6.svg" width="600px">

Documentation is available on the [Terraform website](http://www.terraform.io):

- [Intro](https://www.terraform.io/intro/index.html)
- [Docs](https://www.terraform.io/docs/index.html)

## Deploys

All deploys are managed from the [The Boarderline Terraform Cloud Account](https://app.terraform.io/app/lakegames/workspaces)


<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app"></a> [app](#module\_app) | app.terraform.io/lakegames/app/google | n/a |

## Resources

| Name | Type |
|------|------|
| [terraform_remote_state.app_projects](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.bootstrap](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.folders](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.network](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_disabled"></a> [disabled](#input\_disabled) | Whether triggers and DNS/IP should be disabled | `bool` | `false` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | DNS Domain | `string` | n/a | yes |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | Github org name | `string` | n/a | yes |
| <a name="input_lifecycle_name"></a> [lifecycle\_name](#input\_lifecycle\_name) | Lifecycle name | `string` | n/a | yes |
| <a name="input_repo_name"></a> [repo\_name](#input\_repo\_name) | Github repository name | `string` | n/a | yes |
| <a name="input_tf_org"></a> [tf\_org](#input\_tf\_org) | TF Cloud org name | `string` | n/a | yes |
| <a name="input_use_helm"></a> [use\_helm](#input\_use\_helm) | Whether triggers should deploy with helm | `bool` | `true` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->