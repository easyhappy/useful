#!/usr/bin/env ruby

require 'rubygems'
require 'rack'
require 'rack/lobster'
require 'pry'
require 'soaplet'
require 'doubler'

class Middleware
  def initialize(app)
    @app = app
  end

  def call(env)
    start = Time.now
    @app.call(env)
  end
  
end

app = Rack::Builder.new do
  use Rack::CommonLogger
  use Rack::ShowExceptions
  map '/' do
    binding.pry
    run lambda {|env| [200, {'Content-Type'=>'text/html'}, ['ssssssssssss']] }
  end

  map "/lobster" do
    use Rack::Lint
    run Rack::Lobster.new
  end

end

Rack::Handler::WEBrick.run(app, :Port => 11111)


soaplet = SOAP::WEBrickSOAPlet.new
soaplet.addServant('urn:doublerService', Doubler.new)
app.mount("/doubler", soaplet)
trap("INT"){
  puts 'jjjjjjjjjjjjjj'
  app.shutdown
}
