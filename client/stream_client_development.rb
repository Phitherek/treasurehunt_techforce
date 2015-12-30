require 'faye'
require 'eventmachine'

EM.run do
    client = Faye::Client.new('http://localhost:3000/stream')

    client.subscribe('/stream') do |message|
        if message['type'] == 'request' && message['status'] == 'ok'
            puts "#{message['email']} has sent a request from [#{message['location'][0]}, #{message['location'][1]}] and is #{message['distance']} meters far from treasure."
        elsif message['type'] == 'treasure'
            puts "#{message['email']} is the #{message['num']} treasure hunter to find the treasure!"
        end
    end
end
