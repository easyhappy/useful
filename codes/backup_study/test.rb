class A
  def initialize(&block)
    @before_self = eval 'self', block.binding
    instance_eval(&block) if block_given?
  end

  def method_missing(method, *args, &block)
    @before_self.send method, *args, &block
  end
  def write
    puts 'aa'
  end
end

class B

  def initialize(&block)
    A.new(&block)
  end
  def self.name(which)
    "#{which}_name"
  end
end

def name
  puts 'aaa'
end

B.new do |a|
  a.write
  a.name
end
