#! /usr/bin/ruby
require 'rubygems'
require 'UPnP'

def help
    puts "add_mapping <network port> <local port> <protocol> [description]"
end

# ARGV checking
if ARGV.length < 3 || ARGV.length > 4 then
    puts "Not enough parameters"
    help()
    exit 1
end

# Load from ARGV
nport = nil
lport = nil
protocol = nil
desc = nil
begin
    nport = ARGV[0].to_i
    lport = ARGV[1].to_i
    protocol = ARGV[2]
    if protocol != "TCP" && protocol != "UDP" then
        puts "Protocol muts be TCP or UDP"
        raise
    end
    if ARGV.length == 4 then
        desc = ARGV[3]
    end
rescue 
    puts "Error while parsing the arguments"
    help()
    exit 2
end

begin
    u = UPnP::UPnP.new
    u.addPortMapping(nport,lport,protocol,desc)
rescue UPnP::UPnPException
    puts "UPnP Exception occourred #{$!}"
    exit 3
rescue 
    puts "#{$!}"
    exit 4
end

puts "Mapped #{nport} to #{lport}"
