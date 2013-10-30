#!/home/sun/.rvm/rubies/ruby-1.9.3-p448/bin/ruby

host = Hash.new

host["10"] = 1

puts host["10"]==nil
puts host["xx"]==nil
host["10"]=nil
puts host["10"]==nil
