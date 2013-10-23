#!/home/sun/.rvm/rubies/ruby-1.9.3-p448/bin/ruby

require 'yaml'
class Config

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
    #only one nats
    c_ip = ['nats','ccdb','uaadb','uaadb','vcap_redis','nfs_server',\
            'hbase_master','opentsdb','syslog_aggregator']
    c_ip.each do |str|
      #puts str
      if str != 'nfs_server'
        cf['properties'][str]['address'] = ip[str][0]
      else
        network = ip['debian_nfs_server'][0]
        cf['properties'][str]['address'] = network
        cf['properties'][str]['network'] = network.sub(/\d+$/, '0/24')
      end
    end
    c_ips = ['hbase_slave']
    c_ips.each do |str|
      cf['properties'][str]['addresses'][0] = ip[str][0]
    end
  end

  def output(ymlfile,folder,name)
    File.open(File.join('config',folder,name+".yml"),'w+'){|f|
      f.write(ymlfile.to_yaml) 
    }
  end

  def cf_yml_file_generate(cf,ip)
    exchange cf,ip
    ip.keys.each do |key|
      if key == 'domain' then next end
      if ip[key].size>1
        if cf['properties'].keys.inspect.include? key
          ip[key].each_with_index do |ipp,i|
            cf['properties'][key]['address'] = ipp
            output cf,'cfyml',key+"_"+i.to_s
          end
        end
      else
        output cf,'cfyml',key+"_0"
      end
    end
  end

  def cloud_yml_file_generate(cloudagent,ip)
    nats = ip['nats'][0].chomp
    zkper = ip['zkper'][0].chomp
    ip.keys.each do |key|
      if key == 'domain' then next end
      ip[key].each_with_index do |ipp,i|
        cloudagent['mbus'] = "nats://nats:nats@"+nats+":4222"
        cloudagent['zkp_url'] = zkper+":2181"
        cloudagent['job'] = key
        cloudagent['job_index'] = i
        output cloudagent,'cloudagentyml',key+"_"+i.to_s
      end
    end
  end

  def work()
    iptable = load_yml File.join('config','iptable.yml')
    cf_yml = load_yml File.join('config','cf.yml')
    cf_yml_file_generate cf_yml,iptable
    cloudagent_yml = load_yml File.join('config','cloud_agent.yml')
    cloud_yml_file_generate cloudagent_yml,iptable
  end

end




