require 'eventmachine'
require 'json'

cl = UDPSocket.new
cl.setsockopt(Socket::SOL_SOCKET,Socket::SO_REUSEADDR,1)
cl.setsockopt(Socket::SOL_SOCKET,Socket::SO_BROADCAST,1)
cl.bind('0.0.0.0', 8282)                                
                           

class MusicPlayer < EM::Connection  
  def receive_data(data)           
    puts data
    data = JSON.parse(data)
    if data["to"] == "bunny"
      EM.system("mplayer #{data['value']}") do |output, status|
        send_data({:status => status.exitstatus}.to_json)      
      end
    end
  end
end

EventMachine::run {         
  read = EventMachine.attach(cl, MusicPlayer)  
}