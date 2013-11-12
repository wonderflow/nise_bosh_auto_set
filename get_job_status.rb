#!/home/sun/.rvm/rubies/ruby-1.9.3-p448/bin/ruby

require 'yaml'
require 'net/ssh'
require 'net/scp'
class Status

  def initialize(file)
    @file = file
  end

  def load_yml()
    return YAML::load_file(@file)
  end

  def exec(ssh,ins)
    ssh.open_channel do |channel|
      channel.request_pty do |ch,success|
        raise "I can't get pty request " unless success
        ch.exec(ins)
        ch.on_data do |ch,data|
          if data.inspect.include?"[sudo]"; channel.send_data("password\n")
          else ; puts data.strip ; end
        end
      end
    end
  end

  def connect(host,user,password)
    Net::SSH.start(host,user,:password=>password) do |ssh|
      puts "Examing "+host
      ins = []
      #ins << "sudo /var/vcap/bosh/bin/monit "

      #ins << "cat /proc/cpuinfo | grep 'processor'|sort|uniq |wc -l"
      #ins << "cat /proc/meminfo | grep MemTotal |awk '{print $2}'"
      #ins << "df -Ph / | head -3 |tail -1 |awk '{print $1}'"
      ssh.scp.upload(File.join('config','sudoers'),'.')
      ins << "sudo cp sudoers /etc/sudoers"
      ins.each do |i|
        exec(ssh,i)
      end
      puts host+"Examined"
    end
  end

  def get_through()
    @ip_yml_table.keys.each do |key|
      if key=='domain';next;end
      @ip_yml_table[key].each do |host|
        puts "Job: "+key+" "+host
        `ssh-keygen -f "/home/sun/.ssh/known_hosts" -R #{host}`
        connect(host,"vcap","password")
      end
    end
  end

  def work()
    @ip_yml_table = load_yml
    get_through
  end
end

Status.new(File.join('config','iptable.yml')).work
