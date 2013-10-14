#!/usr/local/ruby/bin/ruby

require 'rubygems'
require 'net/ssh'
require 'net/scp'


def remote_connect(host,user,password)
  Net::SSH.start(host,user,:password=>password) do |ssh|
    puts host+" connected."
    if File.exist?'sources.list'
      ssh.scp.upload!('sources.list','.')
    else
      puts "Error: Don't have File: sources.list!"
      return
    end
    if File.exist?'rubyinstall.sh'
      ssh.scp.upload!('rubyinstall.sh','.')
    else
      puts "Error: Don't have File: rubyinstall.sh!"
      return
    end
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

remote_connect('10.10.102.151','vcap',"password")

