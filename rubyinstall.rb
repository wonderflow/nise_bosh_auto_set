require 'rubygems'
require 'net/ssh'
require 'net/scp'

def send_file(ssh,filename)
  if File.exist?filename
    ssh.scp.upload!(filename,'.')
    return "#{filename} upload Done."
  else
    return "ERROR: Don't have such File: #{filename}"
  end
end

def send_blobs(ssh,srcpath,despath)
  if File.exist?srcpath
    ssh.exec!("mkdir ~/wonderflow/")
    ssh.scp.upload!( srcpath , despath , :recursive => true )do|ch, name, sent, total|
      print "\r#{name}: #{(sent.to_f * 100 / total.to_f).to_i}%"
    end
    print "\n"
    return "#{srcpath} upload Done."
  else
    return "ERROR: Don't have such File: #{srcpath}"
  end
end

def remote_connect(host,user,password)
  filename = File.join("log",host+".log")
  file = File.open(filename,"w")
  Net::SSH.start(host,user,:password=>password) do |ssh|
    puts host+" connected."
    file.puts send_file(ssh,'sources.list')
    file.puts send_file(ssh,'rubyinstall.sh')
    file.puts send_file(ssh,'blobs/ruby-1.9.3-p448.tar.gz')
    file.puts send_file(ssh,'blobs/rubygems-1.8.17.tgz')
    file.puts send_file(ssh,'blobs/yaml-0.1.4.tar.gz')

    ssh.open_channel do |channel|
      channel.request_pty do |ch,success|
        raise "I can't get pty request " unless success
        ch.exec('sudo bash rubyinstall.sh')
        ch.on_data do |ch,data|
          data.inspect
          if data.inspect.include?"[sudo]"
            channel.send_data("password\n")
          else
            file.puts data.strip
          end
        end
      end
    end
  end
end 

list = []
#list << "10.10.102.154"
#list << "10.10.102.155"
#list << "10.10.102.156"
list << "10.10.102.162"

thread = []


list.each do |host|
  thread << Thread.new do
    remote_connect(host,'vcap',"password")
  end
end

thread.each do |x|
  x.join
end

