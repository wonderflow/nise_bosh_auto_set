#!/usr/local/ruby/bin/ruby

require 'rubygems'
require 'net/ssh'
require 'net/scp'

def send_file(ssh,filename)
  if File.exist?filename
    ssh.scp.upload!(filename,'.')do|ch,name,sent,total|
      print "\r#{name}: #{(sent.to_f * 100 / total.to_f).to_i}%"
    end
    puts "\nDone."
  else
    puts "ERROR: Don't have such File: #{filename}"
  end
end

def remote_connect(host,user,password)
  Net::SSH.start(host,user,:password=>password) do |ssh|
    puts host+" connected."
    send_file ssh,'sources.list'
    send_file ssh,'rubyinstall.sh'
    send_file ssh,'ruby-1.9.3-p448.tar.gz'
    ssh.open_channel do |channel|
      channel.request_pty do |ch,success|
        raise "I can't get pty request " unless success
        ch.exec('sudo bash rubyinstall.sh')
        ch.on_data do |ch,data|
          data.inspect
          if data.inspect.include?"[sudo]"
            channel.send_data("password\n")
          else
            puts data.strip
          end
        end
      end
    end
  end
end 

remote_connect('10.10.102.153','vcap',"password")

