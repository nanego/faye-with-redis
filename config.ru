require 'rubygems'
require 'bundler'
Bundler.require
require 'faye'

require File.expand_path('../config/initializers/faye_token.rb', __FILE__)

class ServerAuth
  def incoming(message, callback)
    if message['channel'] !~ %r{^/meta/}
      if message['ext']['auth_token'] != FAYE_TOKEN
        message['error'] = 'Invalid authentication token'
      end
    end
    callback.call(message)
  end
end

faye_server = Faye::RackAdapter.new(
			:mount => '/faye', 
			:timeout => 25,
			:engine => {
				:type => 'redis',
				:host => 'soldierfish.redistogo.com',
				:port => '9990',
				:password => '7a6fda01cb99ab80dca534f22003d699',
				:database => 1
			})
faye_server.add_extension(ServerAuth.new)
run faye_server
