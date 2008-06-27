#! /usr/bin/ruby
require 'rubygems'
require 'UPnP'

begin
    u = UPnP::UPnP.new
    puts "Internet IP #{u.externalIP}"
    puts "Router Lan IP #{u.routerIP}"
    dn,up = u.maxLinkBitrates()
    puts "Max Link Bitrate #{dn}/#{up}"
    s,e,ut = u.status 
    puts "Status #{s}"
    puts "Uptime #{ut}"
    puts "Connection type #{u.connectionType}"
rescue UPnP::UPnPException
    puts "UPnP Exception occourred #{$!}"
rescue 
    puts "#{$!}"
end

