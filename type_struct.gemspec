# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'type_struct/version'

Gem::Specification.new do |spec|
  spec.name          = "type_struct"
  spec.version       = TypeStruct::VERSION
  spec.authors       = ["ksss"]
  spec.email         = ["co000ri@gmail.com"]

  spec.summary       = %q{Pseudo type system on struct.}
  spec.description   = %q{Pseudo type system on struct.}
  spec.homepage      = "https://github.com/ksss/type_struct"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{_test.rb}) }
  spec.require_paths = ["lib"]
end
