require 'rubygems'
require 'net/ssh'
xz = []

25.times do |i|
  var = "10.10.102.1"+(50+i).to_s
  Net::SSH.start(var,'vcap',:password=>"password") do |ssh|
    #ssh.exec!("sudo sed -i -e \'s/mode manual//\' /var/vcap/monit/job/*.monitrc")
    puts "connect success " + var
    puts ssh.exec!("rmdir adeploy")
    puts ssh.exec!("rm adeploy.gz")
  end
end
=begin
File.open("iptables","r+") do |file|
	while line = file.gets
		if(line.strip!="")	
			puts line
		end
	end
end
=end
