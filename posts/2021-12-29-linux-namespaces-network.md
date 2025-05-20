---
title: "Linux Namespaces. Network"
categories: linux
---

In this post, I go through a simple scenario using Linux network namespaces. Here, I create **two network namespaces** and **connect** them using a **virtual ethernet (veth) pair**.

![Two network namespaces connected using veth pair](https://cdn.hashnode.com/res/hashnode/image/upload/v1640811821693/-3lyPlEf5.png)

<p align="center"><em>Image 1. Two network namespaces connected using veth pair</em></p>

---

## Add Network Namespaces

```bash
ip netns add ns-01
ip netns add ns-02
```

---

## List Network Namespaces

```bash
ip netns
```
**Output:**
```bash
ns-02
ns-01
```

Or:

```bash
ls /var/run/netns/
```
**Output:**
```bash
ns-01  ns-02
```

---

## Execute Command in Network Namespace

```bash
ip netns exec ns-01 ip link
```
Or:
```bash
ip -n ns-01 link
```

- `ip link` — command to be executed inside network namespace `ns-01`

---

## Connect Two Network Namespaces

The **veth** devices are virtual Ethernet devices, always created in interconnected pairs. Place one end of a **veth** pair in one network namespace and the other end in another, allowing communication between namespaces.

```bash
ip link add veth-for-ns-01 type veth peer name veth-for-ns-02
```

Inspect:
```bash
ip link | grep -A1 veth-for-ns-01
```
**Output:**
```bash
18: veth-for-ns-02@veth-for-ns-01: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 0e:77:22:e7:68:6e brd ff:ff:ff:ff:ff:ff
19: veth-for-ns-01@veth-for-ns-02: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 06:ad:97:47:a5:17 brd ff:ff:ff:ff:ff:ff
```

Place one end of the **veth** pair in `ns-01` and the other in `ns-02`:

```bash
ip link set veth-for-ns-01 netns ns-01
ip link set veth-for-ns-02 netns ns-02
```

Inspect:
```bash
ip link | grep -A1 veth-for-ns-01
```
At this point, both items (18, 19) won't be present in the list.

Execute inside both namespaces to ensure that **veth** ends are added to the correct network namespaces:

```bash
ip -n ns-01 link
```
**Output:**
```bash
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
19: veth-for-ns-01@if18: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 06:ad:97:47:a5:17 brd ff:ff:ff:ff:ff:ff link-netnsid 1
```

---

## Assign IP Address to Network Namespace's veth

```bash
ip -n ns-01 addr add 192.168.10.1/24 dev veth-for-ns-01
ip -n ns-02 addr add 192.168.10.2/24 dev veth-for-ns-02
```

Inspect:
```bash
ip -n ns-01 addr
```
**Output:**
```bash
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
19: veth-for-ns-01@if18: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 06:ad:97:47:a5:17 brd ff:ff:ff:ff:ff:ff link-netnsid 1
    inet 192.168.10.1/24 scope global veth-for-ns-01
       valid_lft forever preferred_lft forever
```

---

## Bring veth UP

```bash
ip -n ns-01 link set veth-for-ns-01 up
ip -n ns-02 link set veth-for-ns-02 up
```

Inspect:
```bash
ip -n ns-02 link
```
**Output:**
```bash
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
18: veth-for-ns-02@if19: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 0e:77:22:e7:68:6e brd ff:ff:ff:ff:ff:ff link-netnsid 0
```

---

## Check Connection Between Network Namespaces

```bash
ip netns exec ns-01 ping -c1 192.168.10.2
```
**Output:**
```bash
PING 192.168.10.2 (192.168.10.2) 56(84) bytes of data.
64 bytes from 192.168.10.2: icmp_seq=1 ttl=64 time=0.051 ms

--- 192.168.10.2 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.051/0.051/0.051/0.000 ms
```

```bash
ip netns exec ns-02 ping -c1 192.168.10.1
```
**Output:**
```bash
PING 192.168.10.1 (192.168.10.1) 56(84) bytes of data.
64 bytes from 192.168.10.1: icmp_seq=1 ttl=64 time=0.047 ms

--- 192.168.10.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.047/0.047/0.047/0.000 ms
```
