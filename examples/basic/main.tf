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