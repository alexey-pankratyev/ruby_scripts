#!/usr/bin/ruby
# coding: utf-8
# @av.pankratev@tensor.ru
require 'rubygems'
require 'yaml'
require_relative  'vmcon'
require 'trollop'

class GetData
  include Vmcon
  attr_reader :node

  @@opts = Trollop::options do
    banner <<-EOS

  Synchronization of the servers in the Vmware Randeck :

  it is very important to use the need to:
        prcustom.rb [options]
  To add a one server you need to use the parameters: :project, :vmwarevsp, :uservmware, :passwordvmware
  where [options] are:
  EOS
    opt :project, "Name of the project will be created for the server", :type => :string
    opt :tag, "Tag for servers which be display in rundeck", :type => :string
    opt :vmwarevsp, "Specify the host vmvare vsphere", :type => :string
    opt :uservmware, "Specify username of vmware vsphere", :type => :string
    opt :passwordvmware, "Specify password of vmware vsphere", :type => :string
  end

  def initialize
    @host={host: @@opts[:vmwarevsp], user: @@opts[:uservmware], password: @@opts[:passwordvmware] , insecure: true}
    @dt=[]
    @tag = @@opts[:tag]
    @flproject="/var/rundeck/projects/#{@@opts[:project]}/etc/vmwarevsp.yaml"
    @name = lambda { |x| x.to_s.split('(') }
    @node = lambda { |x| @dt<<[x.name,x.guest_ip] if x.name !~ /tpl/ } # you can exclude certain nodes for regexp
  end

  def recvm(fol)
   fol.childEntity.each do |x|
     name, junk = @name.call(x)
     case name
     when "Folder"
        recvm(x)
     when "VirtualMachine"
        @node.call(x)
     else
       p "# Unrecognized Entity " + x.to_s
     end
    end
  end

  def vms # recursively go thru a folder, dumping vm info
    fold
    @vmfold.childEntity.grep(RbVmomi::VIM::Datacenter).each do  |datacenter|
      datacenter.vmFolder.childEntity.each do |folder|
        name, junk = @name.call(folder)
        case name
        when "Folder"
           recvm(folder)
        when "VirtualMachine"
           @node.call(folder)
        else
           puts "# Unrecognized Entity " + folder.to_s
        end
      end
    end
  end

  def get_cloud_yaml(ser=@dt)
    @data=[]
    ser.each do |i|
      nodename=i[0]
      ip=i[1]
      @data <<{nodename => {'description' => nodename,
                  'hostname' => ip,
                  'nodename' => nodename,
                  'tags'=> @tag}}
    end
    File.open(@flproject, 'w') do |f|
      f.write(@data.to_yaml.gsub(/^-/,'').gsub(/^--/,''))
    end
  end

  private

   def fold
    Trollop::die "Need at hostname for vsphere, username for vsphere, password for vsphere and projectname for rundeck! See getsevers.rb -h" unless @@opts[:project] && @@opts[:vmwarevsp] &&  @@opts[:uservmware] && @@opts[:passwordvmware]
    @tag='' if !@tag
    @vmfold=convm(@host)
   end

end

if __FILE__ == $0
    data=GetData.new
    data.vms
    data.get_cloud_yaml
end
