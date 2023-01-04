#!/bin/bash -

# set topology to 1 <-> 2 <-> 3

# isolate all nodes
emaneevent-pathloss -i letce0 1:3 200

# set pathloss 1 <-> 2
emaneevent-pathloss -i letce0 1:2 87

# set pathloss 2 <-> 3
emaneevent-pathloss -i letce0 2:3 87
