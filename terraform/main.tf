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
  billing_account = var.billing_account_id
}

resource "google_storage_bucket" "website_bucket" {
  name     = var.bucket_name
  location = var.location
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

resource "google_service_account" "website_service_account" {
  account_id   = "website-service-account"
  display_name = "Website Service Account"
  project      = google_project.website_project.project_id
}

resource "google_storage_bucket_iam_member" "website_bucket_iam_member" {
  bucket = google_storage_bucket.website_bucket.name
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${google_service_account.website_service_account.email}"
}

# Make bucket public by granting allUsers storage.objectViewer access
resource "google_storage_bucket_iam_member" "public_rule" {
  bucket = google_storage_bucket.website_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}