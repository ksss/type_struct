require 'type_struct/generator'
require 'json'

puts TypeStruct::Generator.new.parse("AutoGeneratedStruct", JSON.load($stdin.read))
