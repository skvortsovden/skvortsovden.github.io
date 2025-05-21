---
title: "What makes container?"
categories: linux
---

When I first time heard about containers, I thought it is some blackbox magic. But after some time I realized that it is not so complicated. In this post I will try to elaborate what makes container.

## Linux kernel features

In the nutshell, container is **a linux process that runs in isolation** from other processes. 

This isolation is achieved by using several Linux kernel features:

- namespaces
- cgroups
- unionfs
- capabilities

Let's take a look at each of these features in more detail.

## Process isolation (PID namespaces)

When I run a process in a container, I want it to be isolated from the host and other containers. This means that it should not be able to see or interact with processes running outside of its own container. 

> For example, if I have a web server running in one container and a database server running in another, I want them to be able to communicate with each other, but I don’t want them to see each other’s processes.

Every container gets its own **/proc** and process tree.

> /proc is a virtual filesystem that exposes kernel data structures, including process info. It shows processes by scanning the host kernel’s global process table.

Inside a PID namespace, the kernel filters /proc entries.

### Hands-on time
Let’s see this in action with a simple example. We’ll create a container and check its process isolation.

```bash
# command
sudo unshare --pid --fork bash
```

How do we know if we are in a new PID namespace? We can check the process ID of the shell we just started:

```bash
# command
echo $$
```

The output should be

```bash
# output
1
```

Which means that we are in a new PID namespace. The shell we started is the first process in this namespace, and its PID is 1.

How can we make sure we are in isolated PID namespace?

First, let's create a new process in the new PID namespace:

```bash
# command
sleep 180 &
```

We can try to kill the process created in the new PID namespace from the host machine.

```bash
# command
pgrep -f "sleep 180"
```

```bash
# output
16363
```

```bash
# command
kill -9 16363
```

```bash
# output
-bash: kill: (16363) - Operation not permitted
```

From the output, we can see that we are not able to kill the process created in the new PID namespace from the host machine. This is because the process is isolated from the host machine.