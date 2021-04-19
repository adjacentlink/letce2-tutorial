# Description

This experiment consists of two radio containers each running an
instance of the EMANE IEEE802.11abg model.

* Each radio container has a lan interface with a connected host
  application container.

* Host application containers use their respective radio as their
  default gateway.

* Radio containers are either running OLSR and advertising their
  attached lan, or running batman-adv with static host routes.


```
[ host-1 ] <-- lan --> [ node-1 ] <-- OTA --> [ node-2 ] <-- lan --> [ host-2 ]
.2      10.98.1.0/24    .1             |       .1     10.98.2.0/24   .2
                                       |
[ host-3 ] <-- lan --> [ node-3 ] <----
   .2      10.98.3.0/24    .1
```

# Address Scheme

| Node | Back Channel | LAN     |  emane0/bat0 |
|------|--------------|---------|--------------|
|node-1|10.99.0.1     |10.98.1.1|10.100.0.1    |
|node-2|10.99.0.2     |10.98.2.1|10.100.0.2    |
|node-3|10.99.0.3     |10.98.3.1|10.100.0.3    |
|host-1|10.99.1.1     |10.98.1.2|              |
|host-2|10.99.1.2     |10.98.2.2|              |
|host-3|10.99.1.3     |10.98.3.2|              |

# Example Ping

```
[me@host exp-03]$ ssh 10.99.1.1
[me@host-1 ~]$ ping -R 10.98.2.2
PING 10.98.2.2 (10.98.2.2) 56(124) bytes of data.
64 bytes from 10.98.2.2: icmp_seq=1 ttl=62 time=4.44 ms
RR: 10.98.1.2
    10.100.0.1
    10.98.2.1
    10.98.2.2
    10.98.2.2
    10.100.0.2
    10.98.1.1
    10.98.1.2

64 bytes from 10.98.2.2: icmp_seq=2 ttl=62 time=5.18 ms	(same route)
...
```

# Topology Change

The change the topology to `1 <-> 2 <->3` use the supplied
topology-make-line.sh script.

```
[me@host exp-03]$  ./scripts/topology-make-line.sh
```
