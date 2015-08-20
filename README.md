# TypeStruct

[![Build Status](https://travis-ci.org/ksss/type_struct.svg)](https://travis-ci.org/ksss/type_struct)

Imitating static typed struct.

## Usage

```ruby
class Sample < TypeStruct.new(
  str: String,
  reg: /exp/,
  num: Integer,
  any: Object,
); end

sample = Sample.new(
  str: "instance of String",
  reg: "not match to regexp",
  num: 10,
  any: true,
)

p sample
#=> #<TypeStructTest::Sample str="instance of String", reg="not match to regexp", num=10, any=true>

p sample.to_h
#=> {:str=>"instance of String", :reg=>"not match to regexp", :num=>10, :any=>true}
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'type_struct'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install type_struct

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
