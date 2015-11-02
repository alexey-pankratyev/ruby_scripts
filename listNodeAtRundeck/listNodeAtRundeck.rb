#!/home/av.pankratev/.rvm/rubies/ruby-2.1.2/bin/ruby
# coding: utf-8
# @av.pankratev@tensor.ru

require 'rubygems'
require 'pg'
require 'yaml'

$file='/tmp/test.yml'

class GetData
	
	DBCON=[ host: "ea1-osr-adm-db2", port: 5432, dbname: "osr-auth", user: "service_user", password: "[bhcj[cjg" ]

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
			when  /^osr/
				tagunix='unix-osr'
				tagswin='win-osr'
			when /\-u\d+\-db/
				tagunix='osr-db'
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

