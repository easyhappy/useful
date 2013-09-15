require 'ripper'
require 'pp'

code = <<STR
10.times do
  puts 'i'
end
STR
puts code
pp Ripper.lex(code)
