# TypeStruct

[![Build Status](https://travis-ci.org/ksss/type_struct.svg)](https://travis-ci.org/ksss/type_struct)

Imitating static typed struct.

## Usage

### Check type

```ruby
class Sample < TypeStruct.new(
  str: String,
  reg: /exp/,
  num: Integer,
  any: Object,
); end

sample = Sample.new(
  str: "instance of String",
  reg: "match to regexp",
  num: 10,
  any: true,
)

p sample
#=> #<Sample str="instance of String", reg="not match to regexp", num=10, any=true>

p sample.to_h
#=> {:str=>"instance of String", :reg=>"not match to regexp", :num=>10, :any=>true}
```

### Mapping from Hash

```ruby
Point = TypeStruct.new(
  x: Integer,
  y: Integer,
)
Color = Struct.new(:code)
Line = TypeStruct.new(
  start: Point,
  end: Point,
  color: Color,
)

hash = JSON.parse(%({"start":{"x":3,"y":10},"end":{"x":5,"y":9},"color":{"code":"#CAFE00"}}))
line = Line.from_hash(hash)

p line
#=> #<Line start=#<Point x=3, y=10>, end=#<Point x=5, y=9>, color=#<struct Color code="#CAFE00">>
p line.start.y
#=> 10
line.stort
#=> NoMethodError
```

## Two special notation

### Union

```ruby
require "union"
Foo = TypeStruct.new(
  bar: Union.new(TrueClass, FalseClass)
)
p Foo.new(bar: false) #=> #<Foo bar=false>
```

or

```ruby
require "union_ext"
using UnionExt
Foo = TypeStruct.new(
  bar: TrueClass | FalseClass,
)
```

### ArrayOf

```ruby
Bar = TypeStruct.new(
  baz: ArrayOf.new(Integer),
)
p Bar.new(baz: [1, 2, 3]) #=> #<Bar baz=[1, 2, 3]>
```

### Mix

```ruby
using UnionExt
Baz = TypeStruct.new(
  qux: ArrayOf.new(Integer | TrueClass | FalseClass) | NilClass
)
p Baz.new(qux: [1]) #=> #<AAA::Baz qux=[1]>
p Baz.new(qux: [true, false]) #=> #<AAA::Baz qux=[true, false]>
p Baz.new(qux: nil) #=> #<AAA::Baz qux=nil>
p Baz.new(qux: 1) #=> TypeError
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
