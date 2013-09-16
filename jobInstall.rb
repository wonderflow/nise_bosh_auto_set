require 'rubygems'
require 'net/ssh'
require 'net/scp'
require 'rye'
File.open("iptables","r+") do |file|
	while line = file.gets
		if(line.strip!=""&&line.index("#")==nil)
			ip,job,index = line.split(" ")
			print ip+" "+job+" "+index+"\n"
			user = "vcap"
			rbox = Rye::Box.new(ip,:user=>"root",:password=>"password")
			rbox.disable_safe_mode
			puts rbox.pwd
			puts rbox.cd '/home/vcap/vcap/deploy/nise_bosh'
			puts rbox.pwd
			puts rbox.execute "/home/vcap/.rbenv/bin/rbenv"
			puts rbox.execute "bundle exec ./bin/nise-bosh -y -f ../cf-release/ ../cf.yml #{job}"
=begin
			Net::SSH.start("#{ip}",'vcap',:password=>"password") do |session|
				puts "started"
				tfile = File.open("tmp.sh","w")
				tfile.puts "cd /home/vcap/vcap/deploy/nise_bosh"
				tfile.puts "/home/vcap/.rbenv/bin/rbenv sudo bundle exec ./bin/nise-bosh -y -f ../cf-release/ ../cf.yml #{job}"
				tfile.close
				session.scp.upload!('tmp.sh','.')
				result = nil
				puts session.exec!("sudo bash tmp.sh") do |channel,stream,data|
					if data =~ /^\[sudo\] password for user:/
						channel.send_data 'password'
					else
						result << data
					end
					#puts session.exec!("/home/vcap/.rbenv/bin/rbenv sudo bundle exec ./bin/nise-bosh -y -f ../cf-release/ ../cf.yml #{job}")
				end
			end
=end
		end
	end
end
