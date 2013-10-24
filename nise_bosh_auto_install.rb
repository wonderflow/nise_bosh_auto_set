#!/home/sun/.rvm/rubies/ruby-1.9.3-p448/bin/ruby

$:.unshift File.dirname(__FILE__)

require 'configload'
require 'autoinstall'


threads = []
installlist = []
config = NiseConfig.new
cf_yml = config.work


cf_yml.keys.each do |key|
  if key=='domain' then next end
  cf_yml[key].each_with_index do |host,index|
    installlist << Install.new(key,index,host,'vcap','password')
  end
end

installlist.each do |ins|
  threads << Thread.new do
    ins.work
  end
end

threads.each do |thread|
  thread.join
end

