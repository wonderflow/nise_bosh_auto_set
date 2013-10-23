#!/home/sun/.rvm/rubies/ruby-1.9.3-p448/bin/ruby

$:.unshift File.dirname(__FILE__)

require 'configload'
require 'rubyinstall'


config = Config.new
config.work

install = Install.new




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

