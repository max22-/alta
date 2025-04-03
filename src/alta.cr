require "./parser"
require "./types"

if ARGV.size != 1
  puts "usage: #{PROGRAM_NAME} file.alta"
  exit 1
end

file_name = ARGV[0]
source = File.read file_name

parser = Parser.new file_name, source
parser.program.each {|r| puts r }