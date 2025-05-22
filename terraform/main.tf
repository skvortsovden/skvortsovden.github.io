terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.5"
    }
  }
}
provider "google" {
  project = var.project_name
  region  = var.region
}

resource "google_project" "website_project" {
  name       = var.project_name
  project_id = var.project_name
}

