---
title: "Hosting personal website on GCP"
date: 2025-05-22
categories: web, cloud, devops
---

I have [this website](https://skvortsovden.github.io/) hosted on GitHub Pages, but I decided to learn how to work with GCP, Github Actions, and Terraform.

So, here we go!

The official documentation on [How to host static website on GCP](https://cloud.google.com/storage/docs/hosting-static-website) is great. 

> I will omit the steps to create a GCP account and set up billing because it's boring.
I'll focus on the high-level steps with some code snippets to illustrate the process.

## Google Cloud Platform (GCP)

GCP have **a free tier** that allows you to host a static website for free.
see: https://cloud.google.com/free/docs/free-cloud-features#storage

> Free Tier is only available in us-east1, us-west1, and us-central1 regions.

GPC is organized into **projects**. Each project has its own resources, billing, and permissions.

So, the **first step is to create a project**.

I am using gcloud CLI to create the project.

```bash
gcloud projects create skvortsovden-website-project
```

Although I like using the CLI more than the web console (old school boy), there is even better approach: to follow **IaC (Infrastructure as Code)** principles.
So, I will use Terraform to create the project and all the resources.

## Terraform

Let's make groundwork for our infrastructure.

Bare minimum terraform configuration to kick off.

I'll start with the **vars.tf** file.

Define variables for:

- project name (the one that is created in GCP)
- region (the one that is free tier eligible)


```hcl
# terraform/vars.tf

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
```

Now, let's create the **main.tf** configuration file.
Terraform automagically reads variables from the file if you name it `vars.tf` and put it in the same directory as `main.tf`.

```hcl
# terraform/main.tf
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
```

The variables are referenced using the `var.<variable_name>` syntax.

Let's terraform the ground.


> If the resource is already created using CLI or WEB UI, you can import it into Terraform state using the `terraform import` command.

```bash
# command
terraform import google_project.website_project projects/skvortsovden-website-project
```

```bash
# output
google_project.website_project: Importing from ID "projects/skvortsovden-website-project"...
google_project.website_project: Import prepared!
  Prepared google_project for import
google_project.website_project: Refreshing state... [id=projects/skvortsovden-website-project]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
```

Nice, my local terraform is synced with the remote GCP resources.

Now, when I run `terraform apply`, it will not create a new project, but will update the existing one.

```bash
# output
google_project.website_project: Refreshing state... [id=projects/skvortsovden-website-project]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```