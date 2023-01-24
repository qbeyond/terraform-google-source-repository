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