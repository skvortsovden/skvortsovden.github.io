---
title: "Kubernetes Pod-to-Pod Communication"
categories: kubernetes
---

In this post, I'll walk through simple scenarios to demonstrate how communication between pods works in Kubernetes.

Assuming you have a Kubernetes cluster (in my case, Minikube deployed locally), you can easily deploy an application:

```bash
$ kubectl run demo-app --image nginx
pod/demo-app created

$ kubectl get po
NAME        READY   STATUS    RESTARTS   AGE
demo-app    1/1     Running   0          5s
```

Now, check if the application is running by executing `curl localhost` inside the container to see the response from the Nginx web server:

```bash
$ kubectl exec -it demo-app -- curl localhost
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
</body>
</html>
```

Cool, now we know `demo-app` is up and running on the default port 80.

Next, let's deploy another application, `demo-app-2`:

```bash
$ kubectl run demo-app-2 --image nginx
pod/demo-app-2 created

$ kubectl get po
NAME         READY   STATUS    RESTARTS   AGE
demo-app     1/1     Running   0          6m45s
demo-app-2   1/1     Running   0          5s
```

Querying `demo-app-2` from inside its container should give the same result:

```bash
$ kubectl exec -it demo-app-2 -- curl localhost
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
</html>
```

Now, let's see how to query `demo-app` from `demo-app-2` and vice versa.

### Using Pod IP Address

First, the easiest way is to use the Pod IP address. Get detailed output with `-o wide`:

```bash
$ kubectl get po -o wide
NAME         READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE   READINESS GATES
demo-app     1/1     Running   0          18m   172.17.0.2   minikube   <none>           <none>
demo-app-2   1/1     Running   0          11m   172.17.0.8   minikube   <none>           <none>
```

Here, you can see the IP addresses assigned to each pod. These IPs come from the same pool, regardless of which node the pods are running on.

Using the IP address of `demo-app`, query it from inside `demo-app-2`:

```bash
$ kubectl exec -it demo-app-2 -- curl 172.17.0.2
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
</body>
</html>
```

This works, but Pod IPs are transient—they change every time a pod is restarted. Also, when scaling the number of pods, you want traffic balanced across all pods, not just one.

### Using a Kubernetes Service

Let's expose our pod to the cluster using a Kubernetes Service. A Service is an abstraction that enables network traffic balancing and routing to your application.

```bash
$ kubectl expose pod demo-app --port 80
service/demo-app exposed

$ kubectl get services
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
demo-app     ClusterIP   10.101.54.82    <none>        80/TCP    18s
```

Now, Kubernetes has created a Service named `demo-app` with its own `CLUSTER-IP`. Use this IP to query `demo-app` from inside `demo-app-2`:

```bash
$ kubectl exec -it demo-app-2 -- curl 10.101.54.82
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
</html>
```

It works! Now, you don't have to rely on the pod's IP address. If it changes, you still have access to the application through the Service.

However, the Service's IP is also transient—it changes if the Service is recreated.

### Using DNS

Kubernetes creates DNS records for Services and Pods. You can contact Services using consistent DNS names instead of IP addresses.

Let's call our `demo-app` through the Service using its DNS name:

```bash
$ kubectl exec -it demo-app-2 -- curl demo-app
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
</html>
```

Here, `demo-app` is the Service name. If your pods are in different namespaces, add `.namespace-name` to the Service name, e.g., `demo-app.default`:

```bash
$ kubectl exec -it demo-app-2 -- curl demo-app.default
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
</html>
```

It works as well! In the example above, we call the `demo-app` Service in the `default` namespace using `curl` from inside the `demo-app-2` pod.

Now, you can rely on the DNS name of the Service and be confident that nothing breaks if either the pods or the Service are recreated.
