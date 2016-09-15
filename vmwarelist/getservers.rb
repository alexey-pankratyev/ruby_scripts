#!/usr/bin/ruby
# coding: utf-8
# @av.pankratev@tensor.ru
require 'rubygems'
require 'yaml'
require_relative  'vmcon'

# $file='/var/rundeck/projects/TEST/etc/cloud_sbis.yaml'
$file='/tmp/cloud_sbis.yaml'

class GetData
  include Vmcon
  attr_reader :node

  def initialize
    @dt=[]
    @name = lambda { |x| x.to_s.split('(') }
    @node = lambda { |x| @dt<<[x.name,x.guest_ip] if x.name !~ /tpl/ }
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
                  'tags'=> 'vmware-vc'}}
    end
    File.open($file, 'w') do |f|
      f.write(@data.to_yaml.gsub(/^-/,'').gsub(/^--/,''))
    end
  end

  private

   def fold
    @vmfold=convm(Vmcon::HOST)
   end

end

if __FILE__ == $0
    data=GetData.new
    data.vms
    data.get_cloud_yaml
end
