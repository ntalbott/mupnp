#! /usr/bin/ruby
# Author: Dario Meloni <mellon85@gmail.com>

require 'test/unit'
require 'rubygems'

class TC_Load < Test::Unit::TestCase

    def test_discover
        require 'UPnP'
        begin
            u = UPnP::UPnP.new(false,1000)
            assert(u.discoverIGD == nil)
        rescue UPnP::UPnPException
            puts "Can't test if no upnp device is found"
        end
    end

end

