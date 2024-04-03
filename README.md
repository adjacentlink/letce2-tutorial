letce2-tutorial
==

# Introduction

The Lightweight Experiment Template Configuration Environment
([letce2][1]) provides a hierarchical mechanism for generating
experiment configuration using the [Mako][2] template engine.

[1]: https://github.com/adjacentlink/letce2
[2]: https://www.makotemplates.org

This tutorial provides a set of experiments to introduce how to use
letce2:

Experiment 00 is a configuration generation experiment that generates
input files used by a separate test control system:

* exp-00: 5 node EMANE IEEE 802.11abg configuration generation.

Experiments 01 through 04 are runnable experiments that use the letce2
LXC experiment control plugin, [letce2-plugin-lxc][3], which adds
features and templates necessary to define and execute experiments:

* exp-01: 10 node EMANE IEEE 802.11abg experiment.

* exp-02: 10 node TDMA Event Scheduler experiment.

* exp-03: 3 node EMANE IEEE 802.11abg experiment with a host
          application container hanging off each radio container.

* exp-04: 10 node EMANE IEEE 802.11abg and TDMA experiment featuring
        [emane-spectrum-tools][9].

* exp-05: 3 node EMANE IEEE 802.11abg experiment with a host
          application container hanging off of each radio container
          using IPv6 host addresses.

[3]: https://github.com/adjacentlink/letce2-plugin-lxc
[9]: https://github.com/adjacentlink/emane-spectrum-tools

In order to run the example experiments, you must install letce2 and
letce2-plugin-lxc either from source or from pre-built binaries
distributed within the latest [EMANE bundles][4].

[4]: https://github.com/adjacentlink/emane/wiki/Install#bundles

This tutorial project is not an introduction to EMANE. Detailed EMANE
information is available from the [EMANE Wiki][5] and the
[EMANE Tutorial][6].

[5]: https://github.com/adjacentlink/emane/wiki
[6]: https://github.com/adjacentlink/emane-tutorial

# letce2-plugin-lxc

Each letce2 node generated using letce2-plugin-lxc, is instantiated as
a Linux LXC Container and is configured with both network stack and
process space isolation. The experiment nodes are not configured with
file system isolation so care must be taken to ensure application
files such as log, lock, pid and Unix sockets are uniquely specified
via their respective application configuration templates.

During a running experiment, nodes are accessed via ssh. The
experiment node init process is a bash script template that may be
tailored to meet experimentation needs.

# Tutorial Layout

The layout of this tutorial: directory and file names and locations, is
not dictated by letce2. However the layout does contain elements that
are required for any letce2 project. So while your layout may differ,
your contents should be similar.

* exp-<INDEX>: Experiment directory, containing node and experiment
  specific configuration. This is the directory you must be in to
  start and stop the respective experiment.

* node.cfg.d: Hierarchical configuration components used as
  inheritable base definitions.

* templates: Mako templates used to create individual experiment node
  application configuration.

The exp-<INDEX> directories contain:

* letce2.cfg: Optional letce2 plugin configuration file. Same for any
  experiment using letce2-plugin-lxc.

* Makefile: A makefile to simplify building and cleaning an
  experiment. This is not required but it is helpful to speed up the
  process.

* experiment.cfg: Experiment configuration. In this tutorial this is a
  single file. Nothing precludes you from using multiple files to
  define various parts of your experiment.

## Address Scheme

LXC container radio nodes have two interfaces: *backchan0* and
*emane0*. The *backchan0* interface is used as the back-channel
control interface as well as the Over-The-Air and Event Channel
interface. The *emane0* interface is the radio interface. Experiments
using batman-adv will as see a *bat0* interface as the radio
interface, with the *emane0* interface attached.

|Test Node|Back Channel Address|Radio Interface Address|
|---------|--------------------|-----------------------|
| 1       | 10.99.0.1          | 10.100.0.1            |
| 2       | 10.99.0.2          | 10.100.0.2            |
| 3       | 10.99.0.3          | 10.100.0.3            |
| 4       | 10.99.0.4          | 10.100.0.4            |
| 5       | 10.99.0.5          | 10.100.0.5            |
| 6       | 10.99.0.6          | 10.100.0.6            |
| 7       | 10.99.0.7          | 10.100.0.7            |
| 8       | 10.99.0.8          | 10.100.0.8            |
| 9       | 10.99.0.9          | 10.100.0.9            |
| 10      | 10.99.0.10         | 10.100.0.10           |

exp-04 has a more complex topology see exp-04/README.md for details.

## Basic Syntax

letce2 uses modified [ConfigParser][7] syntax to define inheritance
hierarchies of abstract definitions that are used to create node
definitions. A node represents an instance of a system whose
configuration is being generated.

[7]: https://docs.python.org/3/library/configparser.html

letce2 operators:

 * `[]`: Operator defining a node or abstract definition using the
  ConfigParser section syntax.

 * `!`: Operator used when defining an abstract definition to indicate
  it as such.

 * `:` Operator specifying the base definition of a derived node or
  abstract definition. Only single inheritance is supported.

 * `@'` Operator defining a variable.

 * `+`: Operator preceding a variable definition to indicate global
  accessibility to all host configuration templates. Normally
  variables are only accessible by their respective node during
  template instantiation.

Experiment nodes are defined using a hierarchical definition that
resembles object oriented programming with single base class
inheritance. For example, the following experiment nodes are defined
in exp-01/experiment.cfg:

```
[node-1:ieee80211abg]
@id=1
[node-2:ieee80211abg]
@id=2
[node-3:ieee80211abg]
@id=3
...
[node-10:ieee80211abg]
@id=10
```

exp-01 defines 10 nodes which are instantiated as 10 LXCs, each
running an instance of `emane`, containing a single IEEE802.11abg
radio model.

In exp-01, each node derives from ieee80211abg which is defined in
node.cfg.d/ieee80211abg.cfg. The `__template.path` and
`__template.file.<INDEX>` variables are special letce2 variables that
allow for specifying the template search path and the individual
templates that make up a definition.

```
[!common:experiment]
__template.file.001=lxc.conf
__template.file.002=lxc.hook.autodev.sh
[!ieee80211abg:common]
__template.path=../templates/radio/ieee80211abg:../templates/radio/common:../templates/common
__template.file.100=init
__template.file.101=init.local
__template.file.102=functions
__template.file.103=platform.xml
__template.file.104=ieee80211abg_mac.xml
__template.file.105=ieee80211abg_nem.xml
__template.file.106=ieee80211abg_pcr.xml
__template.file.107=transvirtual.xml
__template.file.108=eventdaemon.xml
__template.file.109=gpsdlocationagent.xml
__template.file.110=otestpoint.xml
__template.file.111=probe-emane-physicallayer.xml
__template.file.112=probe-emane-ieee80211abg.xml
__template.file.113=probe-emane-virtualtransport.xml
__template.file.114=otestpoint-recorder.xml
__template.file.115=olsr.conf
```

Each template file variable has an index. That index can be used to
override the variable at another point in the base class hierarchy. It
is a good idea to use different index ranges for every derived or
abstract definition hierarchy level, unless you wish to override a
specific template file. In the above example, templates in `common`
start at index 001 and templates in `ieee80211abg` start at 100.

The template search path order is as follows:

1. Directories in order as listed in the colon separated list
contained in `__template.path`.

2. The plugin module's `templates` directory.

3. The root experiment directory.

letce2 uses ConfigParser syntax for indirectly setting a variable
using the value of another variable. For example, the statement:

```
@radio_ip_addr=10.100.0.%(@nem_id)s/24
```

sets `radio_ip_addr` to an IPv4 address generated with the value of
`nem_id`.

You can also set a variable to a value produced from an evaluated
Python expression:

```
@param_1=10
@square_param_a=@eval{str(int(%(@param_1)s) * int(%(@param_1)s))}
```

# Generating Experiment Configuration

To build the configuration for each experiment, enter the experiment
directory and issue the make command.

```
[me @host] cd exp-01
[me@host exp-01]$ make
letce2 \
	lxc \
	build \
	../node.cfg.d/ieee80211abg.cfg \
	experiment.cfg
```

The `letce2 lxc build` command, which is used by the make all rule,
takes as input all the configuration files making up the experiment
definition. For exp-01, `node.cfg.d/ieee80211abg.cfg` contains
the configuration definition for an IEEE802.11abg radio node and
`experiment.cfg` contains server (host) configuration, configuration
that is common to all nodes, and the declaration and configuration of
each node in the experiment.

The output of `letce2 lxc build` is a directory for every node defined
in the experiment. For exp-01, this results in 10 node directories:
`node-1` through `node-10`, and one server directory: `host`.

# Experiment Start and Stop

An experiment can be run with the `letce2 lxc start` command:

```
[me@host] letce2 lxc start
```

Similarly an experiment can be stopped with the `letce2 lxc stop`
command:

```
[me@host] letce2 lxc stop
```

# MANET Routing Protocol

The experiments in this tutorial use batman-adv but can be configured
to use [OLSR](https://github.com/OLSR/olsrd). Modify the following
section(s) of the respective experiment's `experiment.cfg` to switch
protocols. Commented/uncomment `__template.file.200` appropriately.

```
# to use olsr uncomment:
# __template.file.200=olsr.conf
#  and comment:
# __template.file.200=batman-adv
#
# v-- comment/uncomment --v
#__template.file.200=olsr.conf
__template.file.200=batman-adv
# ^-- comment/uncomment --^
```

# Looking for Something More Formal

If you are looking for a more formal test control system, take a look
at the [Extendable Test Control Environment (ETCE)][8]. ETCE is the
test control suite used for EMANE regression testing.

[8]: https://github.com/adjacentlink/python-etce
