# Personal Website
![GitHub Pages](https://img.shields.io/badge/Hosted%20on-GitHub%20Pages-blue.svg)

https://skvortsovden.github.io

This repository contains the source code and content for my personal website, hosted via GitHub Pages.

## Features

- Portfolio and project showcase
- Blog and technical articles
- Contact information

## Technology

Built with [Eleventy](https://www.11ty.dev/).  

To run locally, use:

```bash
npm install
npm start
```

## Terraform

The `terraform` directory contains code for the infrastructure used to host this website on Google Cloud.

```bash
terraform init
terraform apply
```

If **terraform.state is not present** or has been deleted, you can `import` resources from the cloud back into the Terraform state.

Use `terraform import` for each existing resource.

```bash
terraform import google_project.website_project projects/pp-ua-site-project

terraform import google_service_account.website_service_account website-service-account@pp-ua-site-project.iam.gserviceaccount.com

terraform import google_storage_bucket.website_bucket buckets/pp-ua-site-bucket


```

## License

Content and code are provided under the [MIT License](LICENSE).