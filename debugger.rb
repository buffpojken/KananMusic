require 'socket'
require 'json'               

sock = UDPSocket.new                  
sock.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, 1)
payload = {
  "to"    => "bunny", 
  "cmd"   => "play", 
  "from"  => "debugger",
  "value" => "hello"
}
sock.send(payload.to_json+"\n", 0, '0.0.0.0', 8282)
sock.close

#http://compuball.com/av/audio1/HellMarch.mp3