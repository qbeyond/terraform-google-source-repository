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