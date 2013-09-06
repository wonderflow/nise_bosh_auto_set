require 'rubygems'
require 'net/ssh'
File.open("iptables","r+") do |file|
	while line = file.gets
		if(line.strip!="")	
			puts line
			Net::SSH.start("#{line}",'root',:password=>"password") do |ssh|
		       ssh.exec!("sudo sed -i -e \'s/mode manual//\' /var/vcap/monit/job/*.monitrc")
	        end
		end
	end
end
