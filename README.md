# CPU, what did you do?

**WARNING: THIS IS A PROJECT IN EARLY DEVELOPMENT, GIT HISTORY WILL BE REWRITTEN
!!!**

*Perf* is a package for the Julia programming language that enables you
to query the CPU's performance monitoring counters (PMC) which trace how many
CPU instructions have been spent for your process, and on which CPU.  This
feature is provided directly by the CPU, and accessible either directly or
through a Linux kernel driver interface, but requires privileged access.

[![Build Status](https://travis-ci.org/m-j-w/Perf.jl.svg?branch=master)](https://travis-ci.org/m-j-w/Perf.jl)
[![codecov](https://codecov.io/gh/m-j-w/Perf.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/m-j-w/Perf.jl)

[![Perf](http://pkg.julialang.org/badges/Perf.5.svg)](http://pkg.julialang.org/?pkg=Perf)
[![Perf](http://pkg.julialang.org/badges/Perf.6.svg)](http://pkg.julialang.org/?pkg=Perf)

_Status: Proof of concept_

Works on Julia 0.5 and 0.6, Linux only, with Intel compatible CPUs.


## Motivation

Ultimately, Julia generates machine code.  And different coding pattern may
turn out to be different in their computational efficiency.  Is there
a better way than directly asking the CPU whether it has an opinion on this?


## Installation and Usage

*Perf* is a not yet a registered Julia package; clone from GitHub
[master branch](https://github.com/m-j-w/Perf.jl/tree/master):

    Julia> Pkg.clone("https://github.com/m-j-w/Perf.jl")


## Granting monitoring privileges

Linux with a kernel version of at least 2.6.33, enabled performance monitoring
event feature, and privileged access for the same granted to the executing user,
see below.

The performance monitoring capability of the kernel is indicated by the
existence of the file `/proc/sys/kernel/perf_event_paranoid`.


### Kernel monitoring permissions

To be enable to access the Linux kernel provided performance counters, the user
must be granted access by setting a paranoid flag.  The current setting is
obtained from any user account with

    $ cat /proc/sys/kernel/perf_event_paranoid

but setting it requires sudo priviledges:

    $ sudo sh -c 'echo X > /proc/sys/kernel/perf_event_paranoid'

In the above, replace `X` with any of the following integer values, as described
in the Linux kernel sources:

| Paranoia Lvl | Permitted measurements for regular users                          |
|:------------:|:------------------------------------------------------------------|
|      -1      | No restrictions                                                   |
|       0      | Allow access to CPU-specific data but not raw tracepoint samples  |
|       1      | Allow both kernel and user measurements (default on many systems) |
|       2      | Allow only user-space measurements                                |
|      ≥ 3     | Disallow all measurements                                         |


### Direct counter access

The Linux kernel also manages direct access privileges to the CPU's performance
monitoring counters.


### Basic usage




## Features

This initial release provides the basic wrappers to access the Linux kernel
driver and the CPU's performance monitoring counters directly from Julia:

 - When `using Perf`, the module initialises automatically, or gives
     warning messages with instructions to resolve the issue — if possible.
 - `register(::Counter)` creates and registers a new type.
 - `enable(::Counter)` and `disable(::Counter)` selectively toggle counters.
 - `get(::Counter)` retrieves the current counter values.
 - `rdpmc(eax,ecx)` emit a low-level assembly instruction, which may be used if
     direct access privileges are granted, as indicated by `hasrdpmc()`.

**Potential future features** may include improved definition and postprocessing
of results.  However, these features might also go into different packages that
already provide dedicated benchmarking facilities.


## Background

...


## Limitations

...


## Alternatives

**Production-ready alternatives:**
...

**The difference:**
...


## Terms of usage

This Julia package *Perf* is published as open source and licensed under the
[MIT "Expat" License](./LICENSE.md).


**Contributions welcome!**

You're welcome to report successful usage or issues on GitHub, and to open pull
requests to extend the current functionality.

