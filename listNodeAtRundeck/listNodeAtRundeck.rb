#!/home/av.pankratev/.rvm/rubies/ruby-2.1.2/bin/ruby
# coding: utf-8
# @av.pankratev@tensor.ru

require 'rubygems'
require 'pg'
require 'yaml'

$file='/tmp/test.yml'

class GetData
	
	DBCON=[ host: "db2", port: 5432, dbname: "os", user: "user", password: "****" ]

	private_constant :DBCON

	def initialize(dbcon=DBCON)
		@conn = PG::Connection.open(*dbcon)
	end

	def get_cloud_yaml
		sesql
		@data=[]
		@ser.each do |ser|
			nodename=ser.gsub(/\.unix\.tensor\.ru$|\.corp\.tensor\.ru$/, '')
			case ser
			when /^osr-u\d{1,4}-bl1/
				tagunix='osr-bl-1-unix'
			when /^osr-u\d{1,4}-bl2/
				tagunix='osr-bl-2-unix'
			when /^osr-u\d{1,4}-bl3/
				tagunix='osr-bl-3-unix'
			when /^osr-u\d{1,4}-bl4/
				tagunix='osr-bl-4-unix'
			when /^csr-nomcat-bl1|^osr-rev-bl1/
				tagunix='other-bl-1-unix'
			when /^csr-nomcat-bl2|osr-rev-bl2|csr-authlog-bl2/
				tagunix='other-bl-2-unix'
			when /^osr-rev-bl3/
				tagunix='other-bl-3-unix'
			when /^osr-u\d{1,4}-db(1|3)|osr-demo-db1|u7-db2|!u7-db1/
				tagunix='osr-db-master'
			when /^osr-u\d{1,4}-db(2|4)|u7-db1|!u7-db2/
				tagunix='osr-db-slave'
			when /^authlog2-db/
				tagunix='osr-general-db-master'
			when /csr-spp-bl/
				tagunix='spp_BL_linux'				 
			else
				tagunix=''
				tagswin=''
			end  
			if ser=~ /\.unix\.tensor\.ru$/
				@data <<{ser => {'description' => ser,
							  	  'hostname' => ser,
							      'nodename' => nodename,
							      'oSArch' => 'x86_64',
							      'osFamily' => 'unix',
							      'tags'=>tagunix}}
			elsif ser=~ /\.corp\.tensor\.ru$/
				@data <<{ser => {'node-executor' => 'script-exec',
							  	  'hostname' => ser,
							      'nodename' => nodename,
							      'oSArch' => 'winnt',
							      'osFamily' => 'windows',
							      'tags'=>tagswin}}
			end
				
		end
		File.open($file, 'w') do |f| 
			f.write(@data.to_yaml.gsub(/^-/,'').gsub(/^--/,'')) 
		end
	end

	protected
	
		def sesql
			begin
				@ser=[]
				select='SELECT "Название" FROM "Сервер";'.encode('windows-1251')
				res = @conn.exec_params(select)
				res.each { |row|  @ser << row['Название'.encode('windows-1251')] }
			rescue  Exception => msg  
				puts "Error : #{msg}" 
			end
		end

end


if __FILE__ == $0
	
	sql=GetData.new
	sql.get_cloud_yaml

end

