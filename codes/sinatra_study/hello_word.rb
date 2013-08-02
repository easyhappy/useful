require 'sinatra'
require 'rubygems'

get '/' do
  puts '-'*60
  'Hello, world'
end

get '/say/*/to/*' do
  "#{params[:splat][0]} say hello to #{params[:splat][1]}"
end

get %r{/hello/([\w]+)} do
  puts params[:captures]
  "hello #{params[:captures]}"
end
