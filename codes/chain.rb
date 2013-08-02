require 'active_support'
class MyClass
  def greet_with_log
    puts "Calling method..."
    greet_without_log
    puts "...Method called"
  end

  alias_method_chain :log, :greet
  #alias_method :greet_without_log, :greet
  #alias_method :greet, :greet_with_log
end

MyClass.new.greet
