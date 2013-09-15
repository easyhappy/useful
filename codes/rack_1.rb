require 'pry'
require 'rack'
app = Rack::Builder.new {
use Rack::ContentLength
binding.pry
map '/hello' do
run lambda {|env| [200, {"Content-Type" => "text/html"}, ["hello"]] }
end
map '/world' do
run lambda {|env| [200, {"Content-Type" => "text/html"}, ["world"]] }
end
}.to_app
Rack::Handler::WEBrick.run app, :Port => 3333

