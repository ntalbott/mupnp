require File.expand_path("../lib/UPnP/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "mupnp"
  s.version     = UPnP::VERSION
  s.authors     = ["Dario Meloni", "Nathaniel Talbott"]
  s.email       = ["mellon85@gmail.com", "nathaniel@talbott.ws"]
  s.homepage    = "http://github.com/ntalbott/mupnp"
  s.summary     = "UPnP Implementation using the Miniupnpc library"
  s.description = "Makes it easy to poke holes in firewalls."
  s.files       = %w(
    LICENSE
    README.md
    lib/UPnP.rb
    lib/UPnP/version.rb
    ext/Changelog.txt
    ext/LICENSE
    ext/README
    ext/declspec.h
    ext/extconf.rb
    ext/igd_desc_parse.c
    ext/igd_desc_parse.h
    ext/minisoap.c
    ext/minisoap.h
    ext/minissdpc.c
    ext/minissdpc.h
    ext/miniupnpc.c
    ext/miniupnpc.h
    ext/miniwget.c
    ext/miniwget.h
    ext/minixml.c
    ext/minixml.h
    ext/upnp.i
    ext/upnp_wrap.c
    ext/upnpcommands.c
    ext/upnpcommands.h
    ext/upnperrors.c
    ext/upnperrors.h
    ext/upnpreplyparse.c
    ext/upnpreplyparse.h
  )
  s.extensions << "ext/extconf.rb"
end
