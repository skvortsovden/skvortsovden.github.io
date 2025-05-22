# vars.tf
# Define input variables for your Terraform configuration

variable "region" {
    description = "The GCP region to deploy resources in"
    type        = string
    default     = "us-east-1"
}
variable "project_name" {
    description = "Name of the project"
    type        = string
    default     = "pp-ua-site-project"
}

variable "billing_account_id" {
    description = "Billing account ID"
    type        = string
    default     = "01B636-A34826-F48A6B"
}

variable "location" {
    description = "The GCP location to deploy resources in"
    type        = string
    default     = "US"
}

variable "bucket_name" {
    description = "Name of the GCP storage bucket"
    type        = string
    default     = "www.skvortsovden.pp.ua"
  
}
