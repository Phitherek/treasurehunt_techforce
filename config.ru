# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)
require 'faye'

unless ENV['RAILS_ENV'] == 'test'
    use Faye::RackAdapter, mount: '/stream', timeout: 5 do |bayeux|
        bayeux.on(:handshake) do |client_id|
            puts "Streaming endpoint: client #{client_id} connected"
        end
        bayeux.on(:subscribe) do |client_id, channel|
            puts "Streaming endpoint: client #{client_id} subscribed to #{channel}"
        end
        bayeux.on(:unsubscribe) do |client_id, channel|
            puts "Streaming endpoint: client #{client_id} unsubscribed from #{channel}"
        end
        bayeux.on(:publish) do |client_id, channel, data|
            puts "Streaming endpoint: client #{client_id} published on #{channel}: #{data.to_s}"
        end
        bayeux.on(:disconnect) do |client_id|
            puts "Streaming endpoint: client #{client_id} disconnected"
        end
    end
end

run Rails.application
