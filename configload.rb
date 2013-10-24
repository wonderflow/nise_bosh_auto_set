#!/home/sun/.rvm/rubies/ruby-1.9.3-p448/bin/ruby

require 'yaml'
class NiseConfig

  def load_yml(file)
    return YAML::load_file(file)
  end

  #traverse all the yaml tree
  def traverse(obj,&blk)
    case obj
    when Hash
      obj.each{|k,v| traverse(v, &blk)}
    when Array
      obj.each{|v| traverse(v, &blk)}
    else
      blk.call(obj)
    end
  end

  #check old domain and change to the new one
  def domain_change(cf,new)
    old = cf['properties']['domain'].chomp
    #puts "old string is : "+old
    traverse(cf) do |node|
      r = /#{old}/
      if node =~ r
        node.gsub!(old,new)
      end
    end
  end

  def exchange(cf,ip)
    domain_change cf,ip['domain'][0]
    # TODO:wait for change to avoid sturben
    c_ip = ['nats','ccdb','uaadb','vcap_redis','nfs_server',\
            'hbase_master','opentsdb','syslog_aggregator']
    c_ip.each do |str|
      if ip[str] == nil
        puts "warn : no component #{str}" 
        next
      end
      if str != 'nfs_server'
        cf['properties'][str]['address'] = ip[str][0]
      else
        network = ip['debian_nfs_server'][0]
        cf['properties'][str]['address'] = network
        cf['properties'][str]['network'] = network.sub(/\d+$/, '0/24')
      end
    end
    # TODO:wait for change to avoid sturben
    c_ips = ['hbase_slave']
    c_ips.each do |str|
      if ip[str] == nil 
        puts "warn : no component #{str}" 
        next
      end
      cf['properties'][str]['addresses'][0] = ip[str][0]
    end
  end

  def output(ymlfile,folder,name)
    File.open(File.join('config',folder,name+".yml"),'w+'){|f|
      f.write(ymlfile.to_yaml) 
    }
  end

  #cfyml name : jobname_index_cf
  def cf_yml_file_generate(cf,ip)
    exchange cf,ip
    ip.keys.each do |key|
      if key == 'domain' then next end
      if key == 'uaadb'
        cf['properties']['db'] = 'uaadb'
      end
      if key == 'ccdb'
        cf['properties']['db'] = 'ccdb'
      end
      ip[key].each_with_index do |ipp,index|
        if cf['properties'].keys.inspect.include? key
          cf['properties'][key]['address'] = ipp
        end
        output cf,'cfyml',key+"_"+index.to_s+"_cf"
      end
    end
    puts "generate all jobs cf.yml complete."
  end

  #cloudagentyml name: jobname_index_cloud
  def cloud_yml_file_generate(cloudagent,ip)
    # TODO: nats and zkper only have one and choose the first ip 
    #        write into the cloudagent yml
    if ip['nats'] == nil
      puts "ERROR : you don't give nats config! "
      # TODO : need to delete below line and error exit
      nats = '10.10.102.150'
    else
      nats = ip['nats'][0].chomp
    end
    if ip['zkper'] == nil
      puts "ERROR : you don't give zkper config! "
      # TODO : need to delete below line and error exit
      zkper = '10.10.102.150'
    else
      zkper = ip['zkper'][0].chomp
    end

    ip.keys.each do |key|
      if key == 'domain' then next end
      ip[key].each_with_index do |ipp,i|
        cloudagent['mbus'] = "nats://nats:nats@"+nats+":4222"
        cloudagent['zkp_url'] = zkper+":2181"
        cloudagent['job'] = key
        cloudagent['job_index'] = i
        output cloudagent,'cloudagentyml',key+"_"+i.to_s+"_cloud"
      end
    end
    puts "generate all jobs cloudagent.yml complete."
  end

  def shell_generate(iptable)
    iptable.keys.each do |key|
      if key == 'domain' then next end
      File.open(File.join('shell','jobs',key+".sh"),'w+'){|f|
        f.write("cd vcap/deploy/nise_bosh/\n") 
        f.write("sudo bundle exec ./bin/nise-bosh ../cf-release/ ../cf.yml #{key}\n")
      }
    end
    puts "generate all jobs install.sh complete."
  end

  def work()
    iptable = load_yml File.join('config','iptable.yml')
    cf_yml = load_yml File.join('config','cf.yml')
    cf_yml_file_generate cf_yml,iptable
    cloudagent_yml = load_yml File.join('config','cloud_agent.yml')
    cloud_yml_file_generate cloudagent_yml,iptable
    shell_generate iptable
    return iptable
  end

end



