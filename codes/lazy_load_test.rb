require 'active_support'
class HttpClient
  #
  ActiveSupport.run_load_hooks(:http_client, self)
end

class Request
  # ...

  ActiveSupport.on_load :http_client do
    # do something
    puts 'request'
  end
end

class Response
  # ...

  ActiveSupport.on_load :http_client do
    # do something
    puts 'response'
  end
end

#Request.new
class Color
  def initialize(name)
    @name = name

    ActiveSupport.run_load_hooks(:instance_of_color, self)
  end
end

ActiveSupport.on_load :instance_of_color do
  puts "The color is #{@name}"
end

Color.new("yellow")
# => "The color is yellow"
