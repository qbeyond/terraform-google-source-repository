# Google Cloud Source Repository Module

This module allows managing a single Cloud Source Repository, including IAM bindings and basic Cloud Build triggers.

## Examples

### Repository with IAM

```hcl
module "repo" {
  source     = "./fabric/modules/source-repository"
  project_id = "my-project"
  name       = "my-repo"
  iam = {
    "roles/source.reader" = ["user:foo@example.com"]
  }
}
# tftest modules=1 resources=2
```

### Repository with Cloud Build trigger

```hcl
module "repo" {
  source     = "./fabric/modules/source-repository"
  project_id = "my-project"
  name       = "my-repo"
  triggers = {
    foo = {
      filename = "ci/workflow-foo.yaml"
      included_files = ["**/*tf"]
      service_account = null
      substitutions = {
        BAR = 1
      }
      template = {
        branch_name = "main"
        project_id = null
        tag_name = null
      }
    }
  }
}
# tftest modules=1 resources=2
```

<!-- TFDOC OPTS files:1 -->
<!-- BEGIN TFDOC -->

## Files

| name | description | resources |
|---|---|---|
| [iam.tf](./iam.tf) | IAM resources. | <code>google_sourcerepo_repository_iam_binding</code> · <code>google_sourcerepo_repository_iam_member</code> |
| [main.tf](./main.tf) | Module-level locals and resources. | <code>google_cloudbuild_trigger</code> · <code>google_sourcerepo_repository</code> |
| [outputs.tf](./outputs.tf) | Module outputs. |  |
| [variables.tf](./variables.tf) | Module variables. |  |
| [versions.tf](./versions.tf) | Version pins. |  |

## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [name](variables.tf#L44) | Repository name. | <code>string</code> | ✓ |  |
| [project_id](variables.tf#L49) | Project used for resources. | <code>string</code> | ✓ |  |
| [group_iam](variables.tf#L17) | Authoritative IAM binding for organization groups, in {GROUP_EMAIL => [ROLES]} format. Group emails need to be static. Can be used in combination with the `iam` variable. | <code>map&#40;list&#40;string&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [iam](variables.tf#L24) | IAM bindings in {ROLE => [MEMBERS]} format. | <code>map&#40;list&#40;string&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [iam_additive](variables.tf#L31) | IAM additive bindings in {ROLE => [MEMBERS]} format. | <code>map&#40;list&#40;string&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [iam_additive_members](variables.tf#L38) | IAM additive bindings in {MEMBERS => [ROLE]} format. This might break if members are dynamic values. | <code>map&#40;list&#40;string&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [triggers](variables.tf#L54) | Cloud Build triggers. | <code title="map&#40;object&#40;&#123;&#10;  filename        &#61; string&#10;  included_files  &#61; list&#40;string&#41;&#10;  service_account &#61; string&#10;  substitutions   &#61; map&#40;string&#41;&#10;  template &#61; object&#40;&#123;&#10;    branch_name &#61; string&#10;    project_id  &#61; string&#10;    tag_name    &#61; string&#10;  &#125;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [id](outputs.tf#L17) | Repository id. |  |
| [name](outputs.tf#L22) | Repository name. |  |
| [url](outputs.tf#L27) | Repository URL. |  |

<!-- END TFDOC -->

<!-- BEGIN_TF_DOCS -->
## Usage

# Google Cloud Source Repository Module

This module allows managing a single Cloud Source Repository, including IAM bindings and basic Cloud Build triggers.

Original Module from [Cloud-Foundation-Fabric](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric)


## Examples

### Basic

This Module creates a GCP Source Repository
```hcl
provider "google" {
}

resource "random_string" "repo_name" {
  length           = 8
  special          = false
  upper            = false
  numeric          = false
}

resource "google_project_service" "sourcerepo" {
  project = var.project_id
  service = "sourcerepo.googleapis.com"

  disable_on_destroy = false
  disable_dependent_services = false
}

module "repo" {
  depends_on = [google_project_service.sourcerepo]
  source     = "../.."
  project_id = var.project_id
  name       = random_string.repo_name.result
}
variable "project_id" {
  type = string
}
```

### IAM

This Module creates a GCP Source Repository with IAM
```hcl
provider "google" {
  project = var.project_id
}

resource "random_string" "repo_name" {
  length           = 8
  special          = false
  upper            = false
  numeric          = false
}

resource "random_string" "serivce_account_name" {
  length           = 8
  special          = false
  upper            = false
  numeric          = false
}

resource "google_project_service" "sourcerepo" {
  project = var.project_id
  service = "sourcerepo.googleapis.com"

  disable_on_destroy = false
  disable_dependent_services = false
}

resource "google_service_account" "default" {
  account_id   = random_string.serivce_account_name.result
}

module "repo" {
  depends_on = [google_project_service.sourcerepo]
  source     = "../.."
  project_id = var.project_id
  name       = random_string.repo_name.result
  iam = {
    "roles/source.reader" = ["serviceAccount:${google_service_account.default.email}"]
  }
}
variable "project_id" {
  type = string
}
```

### Cloud Build trigger

This Module creates a GCP Source Repository with a Cloud Build Trigger
```hcl
provider "google" {
  project = var.project_id
}

resource "random_string" "repo_name" {
  length           = 8
  special          = false
  upper            = false
  numeric          = false
}

resource "google_project_service" "sourcerepo" {
  for_each = toset(["sourcerepo.googleapis.com", "cloudbuild.googleapis.com"])
  project = var.project_id
  service = each.value

  disable_on_destroy = false
  disable_dependent_services = false
}

module "repo" {
  depends_on = [google_project_service.sourcerepo]
  source     = "../.."
  project_id = var.project_id
  name       = random_string.repo_name.result
  triggers = {
    fooahjsduashduasd = {
      filename        = "ci/workflow-foo.yaml"
      included_files  = ["**/*tf"]
      service_account = null
      substitutions   = {}
      template        = {
        branch_name = "main"
        project_id  = var.project_id
        tag_name    = null
      }
    }
  }
}
variable "project_id" {
  type = string
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.1 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.40.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 4.40.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Repository name. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project used for resources. | `string` | n/a | yes |
| <a name="input_group_iam"></a> [group\_iam](#input\_group\_iam) | Authoritative IAM binding for organization groups, in {GROUP\_EMAIL => [ROLES]} format. Group emails need to be static. Can be used in combination with the `iam` variable. | `map(list(string))` | `{}` | no |
| <a name="input_iam"></a> [iam](#input\_iam) | IAM bindings in {ROLE => [MEMBERS]} format. | `map(list(string))` | `{}` | no |
| <a name="input_iam_additive"></a> [iam\_additive](#input\_iam\_additive) | IAM additive bindings in {ROLE => [MEMBERS]} format. | `map(list(string))` | `{}` | no |
| <a name="input_iam_additive_members"></a> [iam\_additive\_members](#input\_iam\_additive\_members) | IAM additive bindings in {MEMBERS => [ROLE]} format. This might break if members are dynamic values. | `map(list(string))` | `{}` | no |
| <a name="input_triggers"></a> [triggers](#input\_triggers) | Cloud Build triggers. | <pre>map(object({<br>    filename        = string<br>    included_files  = list(string)<br>    service_account = string<br>    substitutions   = map(string)<br>    template = object({<br>      branch_name = string<br>      project_id  = string<br>      tag_name    = string<br>    })<br>  }))</pre> | `{}` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Repository id. |
| <a name="output_name"></a> [name](#output\_name) | Repository name. |
| <a name="output_url"></a> [url](#output\_url) | Repository URL. |

## Resource types
| Type | Used |
|------|-------|
| [google_cloudbuild_trigger](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuild_trigger) | 1 |
| [google_sourcerepo_repository](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sourcerepo_repository) | 1 |
| [google_sourcerepo_repository_iam_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sourcerepo_repository_iam_binding) | 1 |
| [google_sourcerepo_repository_iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sourcerepo_repository_iam_member) | 1 |
**`Used` only includes resource blocks.** `for_each` and `count` meta arguments, as well as resource blocks of modules are not considered.

## Modules

No modules.

## Resources by Files
### iam.tf
| Name | Type |
|------|------|
| [google_sourcerepo_repository_iam_binding.authoritative](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sourcerepo_repository_iam_binding) | resource |
| [google_sourcerepo_repository_iam_member.additive](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sourcerepo_repository_iam_member) | resource |
### main.tf
| Name | Type |
|------|------|
| [google_cloudbuild_trigger.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuild_trigger) | resource |
| [google_sourcerepo_repository.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sourcerepo_repository) | resource |
## Contribute

This module is derived from [google cloud foundation fabric module `source-repository` v19](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric/tree/v19.0.0/modules/source-repository).
It is designed to be able to integrate new changes from the base repository.
Refer to [guide in `terraform-google-landing-zone` repository](https://github.com/qbeyond/terraform-google-landing-zone/tree/main#updating-a-repository) for information on integrating changes.
<!-- END_TF_DOCS -->