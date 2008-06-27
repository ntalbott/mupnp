%module MiniUPnP
%{
#include "miniupnpc.h"
%}

%include "cpointer.i"
%pointer_functions(unsigned int, uintp);

%import declspec.h
%include miniupnpc.h
%include upnpcommands.h
%include igd_desc_parse.h

