#!/home/sun/.rvm/rubies/ruby-1.9.3-p448/bin/ruby

x = []
x << "x"

def changex(p)
  p[0] = "m"
end

puts x
changex x
puts x
