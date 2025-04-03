require "./parser"
require "./types"

if ARGV.size != 1
  puts "usage: #{PROGRAM_NAME} file.alta"
  exit 1
end

file_name = ARGV[0]
source = File.read file_name

def parse(source)
  source.split("|")
end

puts parse(source)

l = Lexer.new source
t = l.next
while t.type != TokenType::EOF
  puts t
  t = l.next
end

parser = Parser.new file_name, source
puts parser.program