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

# Google Cloud Platform (GCP)

GPC is organized into **projects**. Each project has its own resources, billing, and permissions.

So, the first step is to create a project.

I am using gcloud CLI to create the project.

```bash
gcloud projects create skvortsovden-website-project
```

