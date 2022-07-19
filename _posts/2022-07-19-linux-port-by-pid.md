---
layout: post
title:  "Linux. Find port number used by process with CAT and ECHO"
date:   2022-07-19 00:00:00 +0200
categories: linux
---

In this post, I show how to find **port number in-use by process** having its `PID` and using two native linux command - `CAT` end `ECHO` in `BASH`.


## 0. Pick-up some randm PID from processes list on a linux system
```bash
ls /proc
```

output:

```
1   33	  asound     cgroups	consoles  devices    driver	  ...
```

## 1. Print processes TCP connection info

```bash
cat /proc/$YOUR_PID_HERE/net/tcp
```

In my case the command is:

```bash
cat /proc/33/net/tcp
```

output:
```
sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode
0: 00000000:0050 00000000:0000 0A 00000000:00000000 00:00000000 00000000     0        0 2078133 1 000000002283b263 100 0 0 10 0
```

From the output we can pick-up **port number** for `local_address`, which in this case is **0050**.

## 2. Convert PORT number

This value **0050** is **hexadecimal** number, so we need to convert it to **decimal**.

```bash
echo $((16#$YOUR_PORT_HERE))
```

In my case the command is:

```bash
echo $((16#0050))
```

output:

```
80
```

Enjoy your Linux!