#!/usr/bin/ruby
# coding: utf-8
# @av.pankratev@tensor.ru

require 'rubygems'
require 'json'
require 'net/http'
require 'uri'

$page = 'http://media-stat:9615'

def open(url)
  Net::HTTP.get(URI.parse(url))
end

def stat
	page_content = open($page)

	red=JSON.parse(page_content)

	red['processes'].each  do |x| 
  		if x['pm2_env']['status']!='online'
  			return printf "0"
  			break 
  		end
  	end
  	return printf "1"
end

stat








