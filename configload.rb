#!/home/sun/.rvm/rubies/ruby-1.9.3-p448/bin/ruby

require 'yaml'

def get_config(file)
  return YAML::load_file(file)
end

def get_cf_yml(cfyml)
  return YAML::load_file(cfyml)
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
  domain_change(cf,ip['domain'][0])
  #only one nats
  c_ip = ['nats','ccdb','uaadb','uaadb','vcap_redis','nfs_server',\
        'hbase_master','opentsdb','syslog_aggregator']
  c_ip.each do |str|
    #puts str
    if str != 'nfs_server'
      cf['properties'][str]['address'] = ip[str][0]
    else
      cf['properties'][str]['address'] = ip['debian_nfs_server'][0]
    end
  end
  c_ips = ['hbase_slave']
  c_ips.each do |str|
    cf['properties'][str]['addresses'][0] = ip[str][0]
  end
end


iptable = get_config File.join('config','iptable.yml')
cf_yml = get_cf_yml File.join('config','cf.yml')
exchange cf_yml,iptable
File.open(File.join('config','cf.yml'),'r+'){|f|
  f.write(cf_yml.to_yaml)
}
