require 'eventmachine'
require 'json'
require 'evma_httpserver'
require 'cgi'

class APIServer < EM::Connection
  include EM::HttpServer

  def post_init
    super
    no_environment_strings
  end        

  def process_http_request
    params = CGI::parse((@http_query_string || ""))          
    puts params.inspect
    EM.system("mplayer #{params['sound'][0]}") do |output, status|
      puts "Done"
    end
    response = EM::DelegatedHttpResponse.new(self)
    response.status = 200
    response.content_type 'text/javascript'     
    status = {:status => "ok"}
    response.content = "#{params["callback"][0]}(#{status.to_json})"
    response.send_response      
  end
end


class MusicPlayer < EM::Connection  
  def receive_data(data)           
    puts data
    data = JSON.parse(data)
    if data["to"] == "bunny"
      EM.system("mplayer #{data['value']}") do |output, status|
	      puts "Done"
     end
   end
  end
end

cl = UDPSocket.new
cl.setsockopt(Socket::SOL_SOCKET,Socket::SO_BROADCAST,true)
cl.setsockopt(Socket::SOL_SOCKET,Socket::SO_REUSEADDR,true)
cl.bind('0.0.0.0', 8282)                                
                           


EventMachine::run {
  EM.start_server '0.0.0.0', 4568, APIServer      
  read = EventMachine.attach(cl, MusicPlayer) do |c|
	  puts "connect!"
	end
}