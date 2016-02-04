require "forwardable"

class Union
  extend Forwardable
  def_delegators :@classes, :each
  include Enumerable
  def initialize(*classes)
    @classes = classes
  end

  def |(other)
    Union.new(*@classes, other)
  end

  def ===(other)
    @classes.any? { |c| c === other }
  end

  def to_s
    "#<#{self.class} #{@classes.join('|')}>"
  end
  alias inspect to_s
end
