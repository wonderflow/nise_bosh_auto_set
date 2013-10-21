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

#send huge blobs with a proceed tar
def send_blobs(ssh,srcpath,despath)
  if File.exist?srcpath
    ssh.scp.upload!( srcpath , despath , :recursive => true )do|ch, name, sent, total|
      print "\r#{name}: #{(sent.to_f * 100 / total.to_f).to_i}%"
    end
    print "\n"
    return "#{srcpath} upload Done."
  else
    return "ERROR: Don't have such File: #{srcpath}"
  end
end

def send_all(ssh)
  files = []
  files << "sources.list"
  files << "rubyinstall.sh"
  blobs = []
  blobs << "blobs/ruby-1.9.3-p448.tar.gz"
  blobs << "blobs/rubygems-1.8.17.tgz"
  blobs << "blobs/yaml-0.1.4.tar.gz"
  blobs << "adeploy.gz"
  #send some files
  files.each do |f|
    send_file(ssh,f)
  end
  #send the important blob files
  blobs.each do |f|
    send_blobs(ssh,f,'.')
  end
end

def exec_install(ssh,log)
  ssh.open_channel do |channel|
    channel.request_pty do |ch,success|
      raise "I can't get pty request " unless success
      ch.exec('bash rubyinstall.sh')
      ch.on_data do |ch,data|
        data.inspect
        if data.inspect.include?"[sudo]" 
          channel.send_data("password\n")
        elsif data.inspect.include?"Enter your password"
          channel.send_data("password\n")
        else
          log.puts data.strip
        end
      end
    end
  end
end

#connect remote vm and run logical things
def remote_connect(host,user,password)
  filename = File.join("log",host+".log")
  log_file = File.open(filename,"w")
  Net::SSH.start(host,user,:password=>password) do |ssh|
    puts host+" connected."
    send_all ssh
    exec_install ssh,log_file
  end
  log_file.close
end 

list = []
list << "10.10.102.177"

thread = []


list.each do |host|
  thread << Thread.new do
    remote_connect(host,'vcap',"password")
  end
end

thread.each do |x|
  x.join
end

