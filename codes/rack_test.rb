#!/usr/bin/env ruby
require 'rubygems'
require 'rack'
require 'pry'

class HelloRack
    def call(env)
      binding.pry
        [
            200,
            {"Content-Type" => "text/html"},
            ["Hello Rack!"]
        ]
    end
end

Rack::Handler::WEBrick.run(HelloRack.new, :Port => 3001)
