#!/home/sun/.rvm/rubies/ruby-1.9.3-p448/bin/ruby

require 'yaml'
require 'net/ssh'
class Status

  def initialize(file)
    @file = file
  end

  def load_yml()
    return YAML::load_file(@file)
  end

  def exec(ssh,instructor)
    ssh.open_channel do |channel|
      channel.request_pty do |ch,success|
        raise "I can't get pty request " unless success
        ch.exec(instructor)
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
      exec(ssh,"sudo /var/vcap/bosh/bin/monit")
      exec(ssh,"sudo /var/vcap/bosh/bin/monit summary")
      puts host+"Examined"
    end
  end

  def get_through()
    @ip_yml_table.keys.each do |key|
      if key=='domain';next;end
      @ip_yml_table[key].each do |host|
        puts "Job: "+key
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
