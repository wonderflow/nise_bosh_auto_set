require 'rubygems'
require 'net/ssh'
require 'net/scp'

def send_file(ssh,filename)
  if File.exist?filename
    ssh.scp.upload!(filename,'.')
    #return "#{filename} upload Done."
  else
    return "ERROR: Don't have such file: #{filename}"
  end
end

def remote_connect(host,user,password)
  file = File.open("ips","a")
  Net::SSH.start(host,user,:password=>password) do |ssh|
    puts host+" connected!"
    file.puts send_file(ssh,'get_info.sh')
    file.puts "#{host}"
    ssh.open_channel do |channel|
      channel.request_pty do |ch,success|
        raise "I can't get pty request " unless success
        ch.exec('sudo bash Get_vm_info.sh')
        ch.on_data do |ch,data|
          data.inspect
          if data.inspect.include?"[sudo]"
            channel.send_data("password\n")
          elsif data.inspect.include?"Enter your password"
            channel.send_data("password\n")
          else
            file.puts data.strip
          end
        end
      end
    end
  end
  file.close
end

list = []
list << "10.10.102.165"
list << "10.10.102.163"

list.each do |host|
    remote_connect(host,'vcap',"password")
end
