#! /usr/bin/ruby
require 'rubygems'
require 'UPnP'

begin
    u = UPnP::UPnP.new
    u.portMappings.each do |o|
        puts "#{o.to_s}"
    end
rescue UPnP::UPnPException
    puts "UPnP Exception occourred #{$!}"
rescue 
    puts "#{$!}"
end

