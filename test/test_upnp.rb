#! /usr/bin/ruby
# Author: Dario Meloni <mellon85@gmail.com>

require 'test/unit'
require 'rubygems'
require 'UPnP'

class TestUPnP < Test::Unit::TestCase
  def test_discover
    begin
      u = UPnP::UPnP.new(false,1000)
      assert_nil u.discoverIGD
    rescue UPnP::UPnPException
      puts "Can't test if no upnp device is found"
    end
  end
end
