#!/usr/bin/ruby
# coding: utf-8
# @av.pankratev@tensor.ru
require 'rubygems'
require 'yaml'
require 'trollop'
require_relative  'vmcon'

class Createvm

@@opts = Trollop::options do
  banner <<-EOS

Create  servers in vsphere:

it is very important to use the need to:
      createvm [options]
where [options] are:
EOS
  opt :user, "Username for vsphere", :type => :string
  opt :password, "Password for vsphere", :type => :string
  opt :server, "Use server", :type => :string
  opt :ip, "Ip adrees of server", :type => :string
end

p @@opts

Trollop::die "Need at username for vsphere, password for vsphere, servername and ip adress!!!" unless @@opts[:user] && @@opts[:ip] && @@opts[:password] &&  @@opts[:server]

include Vmcon

  def initialize
    @server = @@opts[:server]
    @ip = @@opts[:ip]
    @user = @@opts[:user]
    @password = @@opts[:password]
  end

  def create
    vim
    dc = vim.serviceInstance.find_datacenter or abort "datacenter not found"
    vmFolder = dc.vmFolder
    hosts = dc.hostFolder.children
    puts(hosts)
    puts(vmFolder)
  end

  private

   def vim
    host={host: 'vc.corp.tensor.ru', user: @user, password: @password , insecure: true}
    @vim=con(host)
   end

end

server=Createvm.new
server.create
