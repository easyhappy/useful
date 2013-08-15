require 'webrick'  
require 'pry'
  
server = WEBrick::HTTPServer.new(  
{:Port => 3001, :DocumentRoot => 'C:/webroot'}  
)  
server.start 
