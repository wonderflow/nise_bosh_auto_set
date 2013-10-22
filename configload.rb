#!/home/sun/.rvm/rubies/ruby-1.9.3-p448/bin/ruby

require 'yaml'

$domain = nil

def get_config(file)
  ipyml = YAML::load_file(file)
  $domain = ipyml['domain']
  return ipyml
end

def get_cf_yml(cfyml)
  return YMAL::load_file(cfyml)
end

def exchange(cf,ip)

iptable = ipload File.join('config','iptable.yml')
cf_yml = get_cf_yml File.join('config','cf.yml')
