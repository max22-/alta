require "./parser"
require "./types"
require "./code_gen"

if ARGV.size != 1
  puts "usage: #{PROGRAM_NAME} file.alta"
  exit 1
end

file_name = ARGV[0]
source = File.read file_name

parser = Parser.new file_name, source
ast = parser.parse

File.write "output/output.c", CodeGen.new(ast).generate
