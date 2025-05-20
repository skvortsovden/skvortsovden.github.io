---
title: "Linux: Find Port Number Used by Process with CAT and ECHO"
categories: linux
---

In this post, I'll show how to find the **port number used by a process** when you know its `PID`, using two native Linux commands: `cat` and `echo` in `bash`.

---

## 1. Pick a Random PID

List the contents of `/proc` to see running process IDs:

```bash
ls /proc
```

Example output:

```
1   33   asound   cgroups   consoles   devices   driver   ...
```

---

## 2. Print Process TCP Connection Info

Display TCP connections for a specific process by replacing `$PID` with your process ID:

```bash
cat /proc/$PID/net/tcp
```

For example, with PID 33:

```bash
cat /proc/33/net/tcp
```

Sample output:

```
sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode
0: 00000000:0050 00000000:0000 0A 00000000:00000000 00:00000000 00000000     0        0 2078133 1 000000002283b263 100 0 0 10 0
```

Look for the **local_address** column. The port number is the value after the colon (`:`), here it's `0050`.

---

## 3. Convert the Port Number from Hex to Decimal

The port number (`0050`) is in hexadecimal. Convert it to decimal with:

```bash
echo $((16#0050))
```

Output:

```
80
```

---

Now you know how to find which port a process is using by its PID!
