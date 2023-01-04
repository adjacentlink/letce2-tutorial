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
[ host-1 ]   <-- lan -->   [ node-1 ] <-- OTA --> [ node-2 ]   <-- lan -->   [ host-2 ]
.2     fd00:cc8f:61ff:1::/64   .1             |     .1    fd00:cc8f:61ff:2::/64   .2
                                       |
[ host-3 ]    <-- lan -->    [ node-3 ] <----
   .2    fd00:cc8f:61ff:3::/64    .1
```

# Address Scheme

| Node | Back Channel | LAN               |  emane0/bat0 |
|------|--------------|-------------------|--------------|
|node-1|10.99.0.1     |fd00:cc8f:61ff:1::1|10.100.0.1    |
|node-2|10.99.0.2     |fd00:cc8f:61ff:2::1|10.100.0.2    |
|node-3|10.99.0.3     |fd00:cc8f:61ff:3::1|10.100.0.3    |
|host-1|10.99.1.1     |fd00:cc8f:61ff:1::2|              |
|host-2|10.99.1.2     |fd00:cc8f:61ff:2::2|              |
|host-3|10.99.1.3     |fd00:cc8f:61ff:3::2|              |

# Example Ping

```
[me@host exp-03]$ ssh 10.99.1.1
[me@host-1 ~]$ ping -R fd00:cc8f:61ff:2::2
PING fd00:cc8f:61ff:2::2(fd00:cc8f:61ff:2::2) 56 data bytes
64 bytes from fd00:cc8f:61ff:2::2: icmp_seq=1 ttl=62 time=4.29 ms
64 bytes from fd00:cc8f:61ff:2::2: icmp_seq=2 ttl=62 time=4.44 ms
64 bytes from fd00:cc8f:61ff:2::2: icmp_seq=3 ttl=62 time=4.39 ms
...
```

# Topology Change

The change the topology to `1 <-> 2 <->3` use the supplied
topology-make-line.sh script.

```
[me@host exp-03]$  ./scripts/topology-make-line.sh
```
