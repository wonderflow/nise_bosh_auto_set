#!/home/sun/.rvm/rubies/ruby-1.9.3-p448/bin/ruby

$:.unshift File.dirname(__FILE__)

require 'configload'
require 'autoinstall'
require 'checkvm'

threads = []
install_list = []
config = NiseConfig.new
ip_resource = Hash.new
cf_yml = config.work

check = Check.new(config.load_yml(File.join('config','resource.yml')),cf_yml)
check.work

if check.OK == false
  abort("VM resource is not Enough. Check the VM config or change the resource.yml.")
end

cf_yml.keys.each do |key|
  if key=='domain' || key == 'LB' || key == 'zkper' then next end
  cf_yml[key].each_with_index do |host,index|
    puts host
    `ssh-keygen -f "/home/sun/.ssh/known_hosts" -R #{host}`
    install_list << Install.new(key,index,host,'vcap','password')
  end
end


begin
  puts install_list.size
  install_list.delete_if do |ins|
    #puts ins.host+" tested."
    if ip_resource[ins.host] == nil
     # puts ins.host+" added."
      threads << Thread.new do
        ins.work
      end
      ip_resource[ins.host] = true
      true
    else false end
  end
  threads.each do |thread|
    thread.join
  end
  ip_resource.clear
end while install_list.size != 0

