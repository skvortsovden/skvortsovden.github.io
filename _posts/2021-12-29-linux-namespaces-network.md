---
layout: post
title:  "Linux Namespaces: Network"
date:   2022-12-29 20:55:06 +0200
categories: linux
---

In this post, I go through a simple scenario using Linux network namespaces.
Here I create **two network namespaces** and **connect** them using **virtual ethernet (veth) pair.**


![image.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1640811821693/-3lyPlEf5.png)

<center>*Image 1. Two network namespaces connected using veth pair*</center>

### Add network namespaces

command:

```bash
ip netns add ns-01
```
```bash
ip netns add ns-02
```

---


### List network namespaces

command:
```bash
ip netns
```
output:
```bash
ns-02
ns-01
```
or

command:
```bash
ls /var/run/netns/
```


output:
```bash
ns-01  ns-02
```

---

### Exec command in network namespace

command:
```bash
ip netns exec ns-01 ip link
```

or

```bash
ip -n ns-01 link
```

where:
- **ip link** - command to be executed inside network namespace *ns-01*

---

### Connect two network namespaces


The **veth** devices are virtual Ethernet devices.

**veth** devices are always created in interconnected pairs.

Place one end of a **veth** pair in one network namespace and the other end in another network namespace, thus allowing communication between network namespaces.

command:
```bash
ip link add veth-for-ns-01 type veth peer name veth-for-ns-02
```

inspect:
```bash
ip link | grep -A1 veth-for-ns-01
```
output:
```bash
18: veth-for-ns-02@veth-for-ns-01: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 0e:77:22:e7:68:6e brd ff:ff:ff:ff:ff:ff
19: veth-for-ns-01@veth-for-ns-02: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 06:ad:97:47:a5:17 brd ff:ff:ff:ff:ff:ff
```

Place one end of **veth** pair in ns-01 and the other end in ns-02

command:
```bash
ip link set veth-for-ns-01 netns ns-01
```
```bash
ip link set veth-for-ns-02 netns ns-02
```

inspect:
```bash
ip link | grep -A1 veth-for-ns-01
```

At this point both items (18,19) won't be present in the list.

Execute command inside both namespaces to ensure that **veth** ends are added to corresponded network namespaces.

command:
```bash
ip -n ns-01 link
```

output:
```bash
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
19: veth-for-ns-01@if18: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 06:ad:97:47:a5:17 brd ff:ff:ff:ff:ff:ff link-netnsid 1
```

---

### Assign IP address to Network Namespace's veth

command:
```bash
ip -n ns-01 addr add 192.168.10.1/24 dev veth-for-ns-01
```
```bash
ip -n ns-02 addr add 192.168.10.2/24 dev veth-for-ns-02
```

inspect:
```bash
ip -n ns-01 addr
```
output:
```bash
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
19: veth-for-ns-01@if18: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 06:ad:97:47:a5:17 brd ff:ff:ff:ff:ff:ff link-netnsid 1
    inet 192.168.10.1/24 scope global veth-for-ns-01
       valid_lft forever preferred_lft forever
```

---

### Bringing veth UP

command:
```bash
ip -n ns-01 link set veth-for-ns-01 up
```
```bash
ip -n ns-02 link set veth-for-ns-02 up
```

inspect:
```bash
ip -n ns-02 link
```
output:
```bash
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
18: veth-for-ns-02@if19: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 0e:77:22:e7:68:6e brd ff:ff:ff:ff:ff:ff link-netnsid 0
```

---

### Check connection beetween Network Namespaces

inspect:
```bash
ip netns exec ns-01 ping -c1 192.168.10.2
```
output:
```bash
PING 192.168.10.2 (192.168.10.2) 56(84) bytes of data.
64 bytes from 192.168.10.2: icmp_seq=1 ttl=64 time=0.051 ms

--- 192.168.10.2 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.051/0.051/0.051/0.000 ms
```

inspect:
```bash
ip netns exec ns-02 ping -c1 192.168.10.1
```
output:
```bash
PING 192.168.10.1 (192.168.10.1) 56(84) bytes of data.
64 bytes from 192.168.10.1: icmp_seq=1 ttl=64 time=0.047 ms

--- 192.168.10.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.047/0.047/0.047/0.000 ms
```
