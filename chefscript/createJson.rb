#!/usr/local/rvm/rubies/ruby-2.2.3/bin/ruby
# coding: utf-8
# @av.pankratev@tensor.ru

require 'rubygems'
require 'json'
$recipe= "recipe[bind]" 
$patchNode= '/opt/chef-repo/cookbooks/chef-solo-localNode/bind/'

$n='
    ***********************************************************************************
    * The script creates "node.json" file for define dns zones:                       *
    * Start;launch me with argument:                                                  * 
    *   To specify zones for configurations, write the names of the zones through     * 
    *   the space. The last argument put option (false or true) if this parameter     *	
    *	is set to "false" - this means that the outer zones will not be created       *	
    *	configuration, in the case of the fixed parameter to "true" means that the    *
    *	configuration for the external zone will be created.:                         * 
    *    example for internal zone:                                                   *	
    *       ./createJson.rb example.unix.tensor.ru  example2.unix.tensor.ru  false    *
    *    example for internal & external zone:                                        *	
    *       ./createJson.rb example.unix.tensor.ru  example2.unix.tensor.ru  true     *
    ***********************************************************************************
  '

class Parsing

	def initialize(*args)
		args.each do|a|
  			@args=a
		end
	end

	def checkparam
		if (@args.empty?) or (@args[0] =~ /true|false/) or (@args[-1] !~ /true|false/)
		 	printf $n 
		 	exit 
		end
	end

	def pars
		arr=[]
		lg=[]
		@zone=arr
		@ext=lg
		arr<<@args[0]
		@args[1..-1].each do|a|
		    /false|true/ =~ a.to_s ? lg << a : arr << a					
		end
		puts "My zone: #{@zone},   Zone external?: #{@ext[0]}" 
	end

	def nodeJson
		param = {
    		"run_list": [$recipe],
    		"zone": @zone,
    		"zone_external": @ext[0]
		}
		File.open("#{$patchNode}node.json","w") do |f|
  			f.write(param.to_json)
		end
	end

end

pi = Parsing.new(ARGV)
pi.checkparam
pi.pars
pi.nodeJson
