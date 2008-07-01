#! /usr/bin/ruby
# This module is a binding to the Thomas Bernard miniupnp library
# written in C.  It supports the IGD specification and works with IPv4
# only.  Every exception that comes from inside the library is report as
# UPnPException while wrong arguments are returned as ArgumentError.
#
# Author:: Dario Meloni (mailto:mellon85@gmail.com)
# License:: LGPL

require 'MiniUPnP'
include ObjectSpace

module UPnP
    
    # Represent a port mapping decriptor received from the router.
    class PortMapping
        # Internal address.
        attr_reader :client

        # Internal port.
        attr_reader :lport

        # External port.
        attr_reader :nport

        # External protocol.
        attr_reader :protocol

        # Provided description.
        attr_reader :description

        # Is the mapping enabled?.
        attr_reader :enabled

        # Don't know ...
        attr_reader :rhost

        # Duration of the binding.
        attr_reader :duration

        def initialize(cl,lp,np,p,d,e,rh,du)
            @client = cl
            @lport = lp
            @nport = np
            @protocol = p
            @description = d
            @enabled = e
            @rhost = rh
            @duration = du
        end

        def to_s()
            return "#{@nport}->#{@client}:#{@lport} #{@protocol} for #{@duration} -- #{@description}"
        end
    end


    # Enumeration of protocol values to pass to the library.
    class Protocol
        # TCP protcol
        TCP = "TCP"

        # UDP protocol
        UDP = "UDP"
    end

    # Represents an exception from inside the library.
    class UPnPException < Exception
    end
        

    # The UPNP class represent the binding to the library.  It exports
    # all the functions the library itself exports. 
    class UPnP

        # Max time to wait for a broadcast answer from the routers.
        attr_reader :max_wait_time

        # This will create a new UPnP instance.  max_wait is the maximum
        # time the instance will wait for an answer from the router
        # while seaching or it autodiscover to true will start a thread
        # on the background to scan the network.  All the other
        # functions are safe to be called in the meanwhile, they will
        # just wait for the scan to end before operating.
        def initialize(autodiscover=true,max_wait=1000)
            if max_wait <= 0 then
                raise ArgumentError, "Max wait time must be >= 1."
            end
            if !(autodiscover.is_a? TrueClass) &&
               !(autodiscover.is_a? FalseClass) then
                raise ArgumentError, "Autodiscover must be a boolean value."
            end
            @max_wait_time = max_wait
            # start the discover process at the object initialization.
            # until ruby2, this thread will block the ruby environment
            # for the wait time.
            if autodiscover then
                @igd_thread = Thread.new { discoverIGD }
            else
                @igd_thread = nil
            end
            return nil
        end

        # This method will search for other routers in the network and
        # will wait the specified number of milliseconds that can be
        # ovveridden by the parameter.  It has currently (ruby 1.9) a
        # limitation. As long as thread are cooperative the upnpDiscover
        # function will block the ruby implementation waiting for the
        # library.  If this will not be solved with ruby 2.0 the
        # interface upnp_wrap.c needs to be hacked.  You can avoid to
        # call this function if autodiscover is true.  If no router or
        # no UPnP devices are found an UPnPException is thrown.
        def discoverIGD(max_wait_time=@max_wait_time)
            joinThread()
            if max_wait_time <= 0 then
                raise ArgumentError, "Max wait time must be >= 1"
            end
            @list = MiniUPnP.upnpDiscover(max_wait_time,nil,nil)
            if @list == nil then
                raise UPnPException.new,"No UPNP Device Found"
            end
            define_finalizer(@list,proc {|o| MiniUPnP.freeUPNPDevlist(o)})
            
            @urls = MiniUPnP::UPNPUrls.new
            define_finalizer(@urls,proc {|o| MiniUPnP.FreeUPNPUrls(o)})
            @data = MiniUPnP::IGDdatas.new
            @lan = getCString()

            r = MiniUPnP.UPNP_GetValidIGD(@list,@urls,@data,@lan,64);
            if r == 0 || r == 3 then
                raise UPnPException.new, "No IGD Found"
            end
            @lan = @lan.rstrip()
            return nil
        end

        # Returns the ip of this client
        def lanIP()
            joinThread()
            return @lan
        end

        # Returns the external network ip
        def externalIP()
            joinThread()
            external_ip = getCString()
            r = MiniUPnP.UPNP_GetExternalIPAddress(@urls.controlURL,
                                @data.servicetype,external_ip)
            if r != 0 then
                raise UPnPException.new, "Error while retriving the external ip address. #{code2error(r)}."
            end
            return external_ip.rstrip()
        end

        # Returns the ip of the router
        def routerIP()
            joinThread()
            @data.urlbase.sub(/^.*\//,"").sub(/\:.*/,"")
        end

        # Returns the status of the router which is an array of 3 elements.
        # Connection status, Last error, Uptime.
        def status()
            joinThread()
            lastconnerror = getCString()
            status = getCString()
            uptime = 0
            begin
                uptime_uint = MiniUPnP.new_uintp()
                r = MiniUPnP.UPNP_GetStatusInfo(@urls.controlURL,
                           @data.servicetype, status, uptime_uint,
                           lastconnerror) != 0
                if r != 0 then
                    raise UPnPException.new, "Error while retriving status info. #{code2error(r)}."
                end
                uptime = MiniUPnP.uintp_value(uptime_uint)
            rescue
                raise
            ensure
                MiniUPnP.delete_uintp(uptime_uint)
            end
            return status.rstrip,lastconnerror.rstrip,uptime
        end

        # Router connection information
        def connectionType()
            joinThread()
            type = getCString()
            if MiniUPnP.UPNP_GetConnectionTypeInfo(@urls.controlURL,
                       @data.servicetype,type) != 0 then
                raise UPnPException.new, "Error while retriving connection info."
            end
            type.rstrip
        end

        # Total bytes sent from the router to external network
        def totalBytesSent()
            joinThread()
            v = MiniUPnP.UPNP_GetTotalBytesSent(@urls.controlURL_CIF,
                        @data.servicetype_CIF)
            if v < 0 then
                raise UPnPException.new, "Error while retriving total bytes sent."
            end
            return v
        end

        # Total bytes received from the external network.
        def totalBytesReceived()
            joinThread()
            v = MiniUPnP.UPNP_GetTotalBytesReceived(@urls.controlURL_CIF,
                        @data.servicetype_CIF)
            if v < 0 then
                raise UPnPException.new, "Error while retriving total bytes received."
            end
            return v
        end
        
        # Total packets sent from the router to the external network.
        def totalPacketsSent()
            joinThread()
            v = MiniUPnP.UPNP_GetTotalPacketsSent(@urls.controlURL_CIF,
                        @data.servicetype_CIF);
            if v < 0 then
                raise UPnPException.new, "Error while retriving total packets sent."
            end
            return v
        end
        
        # Total packets received from the router from the external network.
        def totalPacketsReceived()
            joinThread()
            v = MiniUPnP.UPNP_GetTotalBytesSent(@urls.controlURL_CIF,
                        @data.servicetype_CIF)
            if v < 0 then
                raise UPnPException.new, "Error while retriving total packets received."
            end
            return v
        end

        # Returns the maximum bitrates detected from the router (may be an
        # ADSL router) The result is in bytes/s.
        def maxLinkBitrates()
            joinThread()
            up, down = 0, 0
            begin
                up_p = MiniUPnP.new_uintp()
                down_p = MiniUPnP.new_uintp()
                if MiniUPnP.UPNP_GetLinkLayerMaxBitRates(@urls.controlURL_CIF,
                                                         @data.servicetype_CIF,
                                                         down_p,up_p) != 0 then
                    raise UPnPException.new, "Error while retriving maximum link bitrates."
                end
                up = MiniUPnP.uintp_value(up_p)
                down = MiniUPnP.uintp_value(down_p)
            rescue
                raise
            ensure
                MiniUPnP.delete_uintp(up_p)
                MiniUPnP.delete_uintp(down_p)
            end
            return down,up
        end

        # An array of mappings registered on the router
        def portMappings() 
            joinThread()
            i, r = 0, 0
            mappings = Array.new
            while r == 0 
                rhost = getCString()
                enabled = getCString()
                duration = getCString()
                description = getCString()
                nport = getCString()
                lport = getCString()
                duration = getCString()
                client = getCString()
                protocol = getCString()

                r = MiniUPnP.UPNP_GetGenericPortMappingEntry(@urls.controlURL,
                                  @data.servicetype,i.to_s,nport,client,lport,
                                  protocol,description,enabled,rhost,duration)
                if r != 0 then
                    break;
                end
                i = i+1
                mappings << PortMapping.new(client.rstrip,lport.rstrip.to_i,
                                  nport.rstrip.to_i,protocol.rstrip,
                                  description.rstrip,enabled.rstrip,
                                  rhost.rstrip,duration.rstrip)
            end 
            return  mappings
        end

        # Get the mapping registered for a specific port and protocol
        def portMapping(nport,proto)
            checkProto(proto)
            checkPort(nport)
            if nport.to_i == 0 then
                raise ArgumentError, "Port must be an int value and greater then 0."
            end
            joinThread()
            client = getCString()
            lport = getCString()
            if MiniUPnP.UPNP_GetSpecificPortMappingEntry(@urls.controlURL,
                                     @data.servicetype, nport.to_s,proto,
                                     client,lport) != 0 then
                raise UPnPException.new, "Error while retriving the port mapping."
            end
            return client.rstrip, lport.rstrip.to_i
        end

        # Add a port mapping on the router.  Parametes are: network
        # port, local port, description, protocol, ip address to
        # register (or do not specify it to register for yours).
        # Protocol must be Protocol::TCP or Protocol::UDP
        def addPortMapping(nport,lport,proto,desc,client=nil)
            checkProto(proto)
            checkPort(nport)
            checkPort(lport)
            joinThread()
            client ||= @lan if client == nil 
            r = MiniUPnP.UPNP_AddPortMapping(@urls.controlURL,@data.servicetype,
                                nport.to_s,lport.to_s,client,desc,proto)
            if r != 0 then
                raise UPnPException.new , "Failed add mapping: #{code2error(r)}."
            end
        end

        # Delete the port mapping for specified network port and protocol
        def deletePortMapping(nport,proto)
            checkProto(proto)
            checkPort(nport)
            joinThread()
            r = MiniUPnP.UPNP_DeletePortMapping(@urls.controlURL,@data.servicetype,
                                               nport.to_s,proto)
            if r != 0 then
                raise UPnPException.new , "Failed delete mapping: #{code2error(r)}."
            end
        end

        private

        # Generates an empty string to use with the library
        def getCString(len=128)
            "\0"*len
        end

        # Method to wait until the scan is complete
        def joinThread()
            if @igd_thread != nil && Thread.current != @igd_thread then
                @igd_thread.join()
            end
        end
           
        # Check that the protocol is a correct value
        def checkProto(proto)
            if proto != Protocol::UDP && proto != Protocol::TCP then
                raise ArgumentError, "Unknown protocol #{proto}, only Protocol::TCP and Protocol::UDP are valid."
            end
        end

        def checkPort(port)
            iport = port.to_i
            if port.to_i != port || iport < 1 || iport > 65535  then
                raise ArgumentError, "Port must be an integer beetween 1 and 65535."
            end
        end

        def code2error(code)
             case code
             when 402
                 "402 Invalid Args"
             when 501
                 "501 Action Failed"
             when 713
                 "713 SpecifiedArrayIndexInvalid - The specified array index is out of bounds"
             when 714
                 "714 NoSuchEntryInArray - The specified value does not exist in the array"
             when 715
                 "715 WildCardNotPermittedInSrcIP - The source IP address cannot be wild-carded"
             when 716
                 "716 WildCardNotPermittedInExtPort - The external port cannot be wild-carded"
             when 718
                 "718 ConflictInMappingEntry - The port mapping entry specified conflicts with a mapping assigned previously to another client"
             when 724 
                 "724 SamePortValuesRequired - Internal and External port values must be the same"
             when 725 
                 "725 OnlyPermanentLeasesSupported - The NAT implementation only supports permanent lease times on port mappings"
             when 726 
                 "726 RemoteHostOnlySupportsWildcard - RemoteHost must be a wildcard and cannot be a specific IP address or DNS name"
             when 727 
                 "727 ExternalPortOnlySupportsWildcard - ExternalPort must be a wildcard and cannot be a specific port value"
             else
                 "Unknown Error - #{code2error(r)}"
             end
        end
    
    end
end

