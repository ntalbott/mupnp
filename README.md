# UPnP

The gem is based on the work of Thomas Bernard, miniupnp library
(http://miniupnp.free.fr/). The source code and his license can be found in the
ext directory.

There is a little modification in the code. In the original code there was a
compile time switch to receive answer only on the UPnP ports. It is sometimes
useful with certain firewalls to have it enabled, but it may give some problems
with Windows XP. So i have changed it in a run time switch to be passed to
upnpDiscover function. By default it wants to receive answer on the same port
(firewall friendly). If no answer are received from some devices, then maybe a
test with them off (microsoft friendly, may get blocked by firewalls).

The Windows version will be made as long as I have some volunteer that can
provide me the precompiled code for Windows. The library is in the module called
MiniUPnP, in it you can find all the library functions. The module UPnP is a
wrapper that simplify the access to the underlaying library.

The interface was automatically built with swig (http://www.swig.org/), the
interface file is upnp.i


## About

* Original Author: [Dario Meloni](mailto:mellon85@gmail.com)
* License: LGPL
