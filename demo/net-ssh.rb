require 'rubygems'
require 'net/ssh'

def exec(ssh,instructor)
  ssh.open_channel do |channel|
    channel.request_pty do |ch,success|
      raise "I can't get pty request " unless success
      puts "exec: "+instructor
      ch.exec(instructor)
      ch.on_data do |ch,data|
        checkstr = data.inspect
        if data.inspect.include?"[sudo]" 
          channel.send_data("password\n")
        elsif data.inspect.include?"Enter your password"
          channel.send_data("password\n")
        elsif data.inspect.include?"[Y/n]"
          channel.send_data("y\n")
        elsif data.inspect.include?"[y/N]"
          channel.send_data("y\n")
        else
          puts data.strip
        end
      end
    end
  end
  return true
end

25.times do |i|
  var = "10.10.102.1"+(50+i).to_s
  Net::SSH.start(var,'vcap',:password=>"password") do |ssh|
    #ssh.exec!("sudo sed -i -e \'s/mode manual//\' /var/vcap/monit/job/*.monitrc")
    puts "connect success " + var
    puts ssh.exec!("rm -rf adeploy")
    puts ssh.exec!("rm -rf vcap")
    exec(ssh,"sudo rm -rf /var/vcap")
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
