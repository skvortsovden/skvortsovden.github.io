---

title:  "Kubernetes The Fast Way"
categories: kubernetes
---

In this post, I'm going through **Kubernetes** commands trying to use the **imperative approach** as much as possible.  
Below there is **my personal cheat sheet** for Kubernetes administration hands-on.

Enjoy!

## Table of content <!-- omit in toc -->

- [Before you start](#before-you-start)
  - [Install bash-completion on Ubuntu / Debian](#install-bash-completion-on-ubuntu--debian)
  - [Install bash-completion on macOS:](#install-bash-completion-on-macos)
  - [Kubectl autocomplete](#kubectl-autocomplete)
- [Generate manifest yaml output](#generate-manifest-yaml-output)
  - [Generate single pod manifest](#generate-single-pod-manifest)
  - [Generate deployment manifest](#generate-deployment-manifest)
  - [Caution!](#caution)
- [Frequently used commands](#frequently-used-commands)
    - [Run a single pod](#run-a-single-pod)
    - [Check pod status](#check-pod-status)
    - [Delete pod](#delete-pod)
    - [Create deployment](#create-deployment)
    - [Check deployment status](#check-deployment-status)
    - [Scale deployment](#scale-deployment)


## Before you start

I've seen a lot of guys using `k` shortcut (alias) for **kubectl** command.

[This](https://kubernetes.io/docs/reference/kubectl/cheatsheet/#kubectl-autocomplete) documentation page mentions `k` alias as well.


### Install bash-completion on Ubuntu / Debian

```bash
sudo apt install bash-completion
```

### Install bash-completion on macOS:

```bash
brew install bash-completion
```

### Kubectl autocomplete

```bash
echo "source <(kubectl completion bash)" >> ~/.bashrc &&\
echo "alias k=kubectl" >> ~/.bashrc &&\
echo "complete -F __start_kubectl k" >> ~/.bashrc
```

## Generate manifest yaml output

Working with **kubectl** I found one more convenient alias which saved me a lot of time.

```bash
alias kg="kubectl -o yaml --dry-run=client" # generate manifest yaml output, 'g' for generate
```

Then you can use it as follow:

### Generate single pod manifest

```bash
kg run webserver-pod --image nginx
```

output:

```
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: webserver-pod
  name: webserver-pod
spec:
  containers:
  - image: nginx
    name: webserver-pod
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

### Generate deployment manifest

```bash
kg create deploy webserver --image nginx --replicas 3
```

output:

```
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: webserver
  name: webserver
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webserver
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: webserver
    spec:
      containers:
      - image: nginx
        name: nginx
        resources: {}
status: {}
```

### Caution!

Although aliases might be super-efficient while working on your own machine it could be harmful when it comes to working in a managed environment where you are limited with default commands only.

It's up to you to stick with default or leverage shortcuts.


## Frequently used commands

#### Run a single pod

with given name ***webserver*** and image ***nginx***:

```bash
kubectl run webserver --image nginx # run a single pod
```

```bash
kubectl run webserver --image nginx -l env=dev,tier=frontend # run a single pod with labels
```

```bash
kubectl run webserver --image nginx --env "env=prod" --env "tier=frontend" # run a single pod with environment variables set
```


![pod](https://cdn.hashnode.com/res/hashnode/image/upload/v1640729377064/hcOm7qtMx.png)
<center>*Image 1. single pod in default namespace*</center>



#### Check pod status

Check if pod is created and running:
```bash
kubectl get po # this command list all pods in the current namespace
```

or (if you have a bunch of pods) get pod status by its name (*webserver*):

```bash
kubectl get po webserver # get pod by name webserver
```
#### Delete pod
```bash
kubectl delete po webserver # delete pod by name webserver
```

#### Create deployment 

with given name ***websever-dep*** and image ***nginx***:

```bash
kubectl create deploy webserver-dep --image nginx 
```


![deployment.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1640731788666/YayBeLx4L.png)
<center>*Image 2. deployment with replicaset and single pod in default namespace*</center>

#### Check deployment status

```bash
kubectl get deploy # this command list all deployment in the current namespace
```

#### Scale deployment

```bash
kubectl scale deploy webserver-dep --replicas 3 # scale up to 3
```

![scale.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1640734380415/LKB3FwM6F.png)
<center>*Image 3. deployment scaled up to 3*</center>

