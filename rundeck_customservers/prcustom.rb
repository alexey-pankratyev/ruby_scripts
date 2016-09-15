#!/usr/bin/ruby
# coding: utf-8
# @av.pankratev@tensor.ru
require 'rubygems'
require 'yaml'
require 'trollop'

class Createsrv

  @@opts = Trollop::options do
    banner <<-EOS

  Create  servers in rundeck projects:

  it is very important to use the need to:
        prcustom.rb [options]
  To add a one server you need to use the parameters: servername: and :ip,
  if  you like add a many server from the list, you need to specify the file parameter :file
  where [options] are:
  EOS
    opt :project, "Name of the project will be created for the server", :type => :string
    opt :tag, "Tag for servers which be display in rundeck", :type => :string
    opt :file, "Fail the listed servers", :type => :string
    opt :servername, "Use server", :type => :string
    opt :ip, "Ip adrees of server", :type => :string
  end

  def initialize
    @dt=[]
    @project = @@opts[:project]
    @ip = @@opts[:ip]
    @servername = @@opts[:servername]
    @tag = @@opts[:tag]
    @file = @@opts[:file]
    @flproject="/var/rundeck/projects/#{@@opts[:project]}/etc/cloudcustom.yaml"
    @flservers="#{@@opts[:file]}"
  end

  def get_cloud_yaml(ser=@dt)
    @data=[]
    if @ip && @servername && @project && !@file
        ser<<[@servername,@ip]
        Trollop::die "ip address is incorrect!" unless @ip =~ /^\d+\.\d+\.\d+\.\d+/
    elsif @file && @project && !@ip && !@servername
      File.open(@flservers, "r") do |f|
        f.each_line.with_index  do |line,index|
          ser<<line.split(' ')
          Trollop::die "When Fail to specify servers, it lists the server in a column, the first parameter of the server name, IP address second!" unless ser[index][1].gsub(/"/,'') =~ /^\d+\.\d+\.\d+\.\d+/
        end
      end
    elsif !@tag
      @tag=''
    else
      Trollop::die "Need at options:\n--project, --tag, --file\nOR\n--project, --tag, --servername, --ip"
    end

    ser.each do |i|
      nodename=i[0]
      ip=i[1]
      @data<<{nodename => {'description' => nodename,
                  'hostname' => ip,
                  'nodename' => nodename,
                  'tags'=> @tag }}

    end

    File.open(@flproject, 'a') do |f|
      f.write(@data.to_yaml.gsub(/^-/,'').gsub(/^--/,'')) if !@data.empty?
    end

  end

end

if __FILE__ == $0
  data=Createsrv.new
  data.get_cloud_yaml
end
