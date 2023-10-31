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

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    [
      %w[LICENSE.txt README.md],
      Dir.glob("lib/**/*.*").grep_v(/_test\.rb\z/),
    ].flatten
  end
  spec.require_paths = ["lib"]
end
