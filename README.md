# TypeStruct

[![Build Status](https://travis-ci.org/ksss/type_struct.svg)](https://travis-ci.org/ksss/type_struct)

Imitating static typed struct.

All type is checked by `===` method.

## Usage

### Check type

```ruby
Sample = TypeStruct.new(
  str: String,
  reg: /exp/,
  num: Integer,
  any: Object,
)

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

p sample.str
#=> "instance of String"

sample.string #=> NoMethodError
sample.str = 1 #=> TypeError
```

### Mapping from Hash

Generate object from hash recursive

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

## Four special notation

### Union

Union is a object express class that some classes as one class like crystal `Union`.

`Union#===` check all object with `===` method.

```ruby
Foo = TypeStruct.new(
  bar: TypeStruct::Union.new(TrueClass, FalseClass)
)
p Foo.new(bar: false) #=> #<Foo bar=false>
```

or add `Class#|` method by refinements

```ruby
require "type_struct/ext"
using TypeStruct::Union::Ext
Foo = TypeStruct.new(
  bar: TrueClass | FalseClass,
)
```

### ArrayOf

ArrayOf is a object express array type.

`ArrayOf#===` check all item with `===` method.

```ruby
Bar = TypeStruct.new(
  baz: TypeStruct::ArrayOf.new(Integer),
)
p Bar.new(baz: [1, 2, 3]) #=> #<Bar baz=[1, 2, 3]>
```

### HashOf

`HashOf#===` check all keys and values with `===` method.

```ruby
Baz = TypeStruct.new(
  qux: TypeStruct::HashOf.new(String, TypeStruct::ArrayOf.new(Integer))
)
p Baz.new(qux: { "a" => [1, 2, 3] }) #=> #<Baz qux={"a"=>[1, 2, 3]}>
p Baz.from_hash(qux: { "a" => [1, 2, 3] }) #<Baz qux={"a"=>[1, 2, 3]}>
p Baz.new(qux: { :a  => [1, 2, 3] }) #=> TypeError
p Baz.new(qux: { "a" => [1, 2, nil] }) #=> TypeError
```

### Interface

Interface is a object for duck typing like golang `interface`.

`Interface#===` check all method using `respond_to?`

```ruby
Foo = TypeStruct.new(
  bar: TypeStruct::Interface.new(:read, :write)
  # or Interface.new(:read, :write) on required 'type_struct/ext'
)
Foo.new(bar: $stdin)
Foo.new(bar: 1) #=> TypeError
```

### Mix

```ruby
require "type_struct/ext"
using TypeStruct::Union::Ext
Baz = TypeStruct.new(
  qux: ArrayOf(Integer | TrueClass | FalseClass) | NilClass
)
p Baz.new(qux: [1]) #=> #<AAA::Baz qux=[1]>
p Baz.new(qux: [true, false]) #=> #<AAA::Baz qux=[true, false]>
p Baz.new(qux: nil) #=> #<AAA::Baz qux=nil>
p Baz.new(qux: 1) #=> TypeError
p Baz.from_hash(qux: [1, 2, false, true]) #=> #<A::Baz qux=[1, 2, false, true]>
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
