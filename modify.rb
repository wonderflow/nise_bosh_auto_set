require 'rubygems'
require 'net/ssh'
File.open("iptables","r+") do |file|
        while line = file.gets
                if(line.strip!="")
                        ip,job,index = line.split(" ")
                        puts ip,job,index
                        Net::SSH.start("#{ip}",'root',:password=>"password") do |ssh|
                                ssh.exec!("sudo sed -i -e \'s/job: changeme/job: #{job}/g\' /home/vcap/wonderflow/wonderflow-test/cloud_agent.yml")
                                if(index!=0)
                                        ssh.exec!("sudo sed -i -e \'s/job_index: 0/job_index: #{index}/g\' /home/vcap/wonderflow/wonderflow-test/cloud_agent.yml")
                                end
                        end
                end
        end

end
