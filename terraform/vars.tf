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
    default     = "skvortsovden-website-project"
}