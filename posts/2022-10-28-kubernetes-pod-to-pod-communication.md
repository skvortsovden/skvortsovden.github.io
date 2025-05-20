---

title:  "Kubernetes Pod-to-Pod communication"
categories: kubernetes
---

In this post I am going to go over simple scenarios in order to show how communication between pods works in Kubernetes.

Assuming we have kubernetes cluster, in my case it is minukube deployed locally, we can deploy application easily.

```
denys@leasure[~] :$ kubectl run demo-app --image nginx
pod/demo-app created
denys@leasure[~] :$ kubectl get po
NAME        READY   STATUS    RESTARTS      AGE
demo-app    1/1     Running   0             5s
```

Now we can check if our application is running. We can execute command `curl localhost` inside container and see response from nginx webserver.

```
denys@leasure[~] :$ kubectl exec -it demo-app -- curl localhost
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
</body>
</html>
```

Cool, now we know `demo-app` is up and running on default port 80.
Next, let's deploy one more application `demo-app-2`.

```
denys@leasure[~] :$ kubectl run demo-app-2 --image nginx
pod/demo-app-2 created
denys@leasure[~] :$ kubectl get po
NAME         READY   STATUS    RESTARTS   AGE
demo-app     1/1     Running   0          6m45s
demo-app-2   1/1     Running   0          5s
```

Apparently quering `demo-app-2` from inside the container should give us the same result as for `demo-app`.

```
denys@leasure[~] :$ kubectl exec -it demo-app-2 -- curl localhost
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
</html>
```

Now let's see how we can query `demo-app` from `demo-app-2` and other way around.

First and the easiest way is using POD IP address. Let's get more detailed output by adding `-o wide`

```
denys@leasure[~] :$ kubectl get po -o wide
NAME         READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE   READINESS GATES
demo-app     1/1     Running   0          18m   172.17.0.2   minikube   <none>           <none>
demo-app-2   1/1     Running   0          11m   172.17.0.8   minikube   <none>           <none>
```

Here we can see IP addresses assigned to each node.
Each of these IP addresses is coming from the same pool no matter on which Node PODs are running.

Using IP adress of `demo-app` we can query it from inside `demo-app-2`.

```
denys@leasure[~] :$ kubectl exec -it demo-app-2 -- curl 172.17.0.2
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
</body>
</html>
```

Cool, that works fine. This is one of the easiest ways to check connection between two PODs.
But we can't rely on IP adresses since they are transient, they change everytime POD is restarted. Moreover, when we scale number of PODs running the same application we would want to have traffic balancing accross all PODs instead of hitting one of them every time.

Let's expose our POD to the cluster and make it available through Kubernetes Service.
Service in Kubernetes is just an abstract layer on top of your POD which enables network traffic balancing and routing to your application.

```
denys@leasure[~] :$ kubectl expose pod demo-app --port 80
service/demo-app exposed
denys@leasure[~] :$ kubectl get services
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
demo-app     ClusterIP   10.101.54.82     <none>        80/TCP    18s
```

All we have to do is just to specify Pod name `demo-app` and port numbe `--port 80`.
And now Kubernetes Service is created with the same name as Pod and it's own `CLUSTER-IP`. Let's use this IP to querey `demo-app` from inside `demo-app-2`.

```
denys@leasure[~] :$ kubectl exec -it demo-app-2 -- curl 10.101.54.82
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
</html>
```

It works! Cool, now we do not stick to Pod's IP address and if it changes we still have access to application though Service.

Although Kubernetes Service provides us with traffic balancing so that we don't care about Pod's IP anymore it has it's own IP which is transient as well.

Now the problem is that if our Service is recreated it's IP address is going to be changed as well.

The solution is DNS.

Kubernetes creates DNS records for Services and Pods. You can contact Services with consistent DNS names instead of IP addresses.

Let's call our `demo-app` though the Service using it's DNS name.

```
denys@leasure[~] :$ kubectl exec -it demo-app-2 -- curl demo-app
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
</html>
denys@leasure[~] :$
```

Here we use DNS `demo-app` which is the same as Service name. In case our Pods are in different namespaces we should add `.namespace-name` to Service name and get DNS like `demo-app.default`.

```
denys@leasure[~] :$ kubectl exec -it demo-app-2 -- curl demo-app.default
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
</html>
denys@leasure[~] :$
```

Cool, it works as well.
So in the example above we call `demo-app` service in the `default` namespace using `curl` tool from inside `demo-app2` Pod.

Now we can rely on DNS name of the Service and make sure nothing brakes after either Pods or Service has been recreated.