require 'eventmachine'

module EchoServer
  def post_init
    puts 'Someone connect to this server'
  end

  def receive_data data
    send_data ">>> you sent data: #{data}"
    close_connection  if data =~ /quit/i
  end

  def unbind
    puts 'left this server'
  end
end

EventMachine.run{
  EventMachine.start_server '127.0.0.1', 8080, EchoServer
}
