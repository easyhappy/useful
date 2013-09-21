require 'grape'
require 'rack'
require 'sinatra'

class Api < Grape::API
  get :hello do
    {hello: :word}
  end
end

class Web < Sinatra::Base
  get '/' do
    "Hello world."
  end
end

use Rack::Session::Cookie
Rack::Handler::WEBrick.run(Rack::Cascade.new [Api, Web])
