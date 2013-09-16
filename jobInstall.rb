require 'rubygems'
require 'net/ssh'
File.open("iptables","r+") do |file|
        while line = file.gets
                if(line.strip!=""&&line.index("#")==nil)
                        ip,job,index = line.split(" ")
                        puts ip,job,index
                        Net::SSH.start("#{ip}",'vcap',:password=>"password") do |ssh|
                        puts "started"
                        ssh.exec!("cd /home/vcap/vcap/delploy/nise_bosh")
                        ssh.exec!("ls")
                        ssh.exec!("rbenv sudo bundle exec ./bin/nise-bosh -y -f ../cf-release/ ../cf.yml #{job}")
                        end
                end
        end
end
