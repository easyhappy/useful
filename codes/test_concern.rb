require 'active_support'
require 'pry'

module Baz
  extend ActiveSupport::Concern
  def baz
    puts "baz!"
  end
end

module Bar
  extend ActiveSupport::Concern
  include Baz
  def bar
    puts "bar!"
  end
end

module Foo
  extend ActiveSupport::Concern
  include Bar
end

class Zoo
  include Foo
end
puts Zoo.ancestors.inspect
