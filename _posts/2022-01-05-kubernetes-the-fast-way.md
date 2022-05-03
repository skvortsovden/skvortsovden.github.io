---
layout: post
title:  "Kubernetes Users"
date:   2022-01-05 20:55:06 +0200
categories: kubernetes
---

First thing first, there is **no** such object as a **user in Kubernetes**.  
**Certificates** are used for authentification and authorization.

So **a user** in Kubernetes is represented as **a certificate owner**.



![Untitled-2022-01-04-1425.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1641300538497/jKwrpsEIg.png)


In order **to give access for a user** (certificate owner) to your cluster a user's **certificate should be signed** by the certificate authority that your cluster trust.


> 
A few steps are required in order to get a normal user to be able to authenticate and invoke an API. First, this user must have a certificate issued by the Kubernetes cluster, and then present that certificate to the Kubernetes API.

source: [https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#normal-user](https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#normal-user)

