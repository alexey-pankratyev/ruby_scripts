#! /usr/bin/ruby 
# coding: utf-8
# @av.pankratev@tensor.ru
require 'rubygems'
require 'net/ssh'
require 'socket'
require 'timeout'
 
class Check_mongo
  attr_reader :mongodb,:port  
  
  def initialize(mongodb)
    @mongodb = mongodb
  end
  
  def checkmongo
    stdout = ""
    Net::SSH.start(@mongodb, 'root',  :keys => [ "/home/zabbix/.ssh/id_zabbix" ], :timeout => 5) do |ssh|
     ssh.exec!(" echo   $(mongo -u admin -p Xi9baN1KuK 127.0.0.1/admin --eval 'JSON.stringify(rs.status())';)| tr ',' '\n'") do |channel, stream, data|
      if stream == :stderr 
        return "0"
       else
        stdout << data if stream == :stdout
       res = "" 
        stdout.each_line { |li| if (li[/state\":/]) 
                          i = li.gsub(/\"state\":/, '')
                          res += i 
                          end }
        res.each_line  { |lis| unless  (lis[/1|2/]) 
                          return "0"
                          end}
                            
       return "1"  
      end
      ssh.loop
     end
    end
     rescue 
     return "0" 
  end

end
  
class Ports < Check_mongo

 def initialize(port,host)
  @port = port
  @host = host
 end

 def checkport(host,port)
    Timeout::timeout(1) { TCPSocket.new(host, port) }
    puts 1
    # do some stuff here...
   rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH,  SocketError
    puts 0
    # do some more stuff here...
   rescue Timeout::Error
    puts 0 
    # do some other stuff here...
 end
end

n='
    ***********************************************************************************
    * Scripts checking the service of   "management traffic manager"                  *
    * Start;launch me with argument:                                                  * 
    *   1.)For checking cluster MongoDB with parameter: md:(your host)                * 
    *           example: ./managingadm.rb md:managing-dispatch.unix.tensor.ru         *
    *   2.)For check of accessibility of the port on server: (your host) (your port)  *
    *           example: ./managingadm.rb managing-dispatch.unix.tensor.ru 80         *
    ***********************************************************************************
  '

if (ARGV.empty?) or (ARGV.length == 2 and   ARGV[0] =~  /md\:*/ ) or ( ARGV[0] !~  /md\:*/ and ARGV.length == 1 ) or (ARGV.length.between?(3, 99))
    puts n    
   elsif ( ARGV[0] =~  /md\:*/ )
       res = ARGV[0].gsub(/md\:/, '')
       mn = Check_mongo.new(res)
       puts(mn.checkmongo)
   elsif (ARGV.length == 2) 
       pi = Ports.new(ARGV[0],ARGV[1])
       pi.checkport(ARGV[0],ARGV[1])     
end


