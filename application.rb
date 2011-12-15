require "bundler"
require "rubygems"

module Stream
  class Application

    def self.root(path = nil)
      @_root ||= File.expand_path(File.dirname(__FILE__))
      path ? File.join(@_root, path.to_s) : @_root
    end

    def self.env
      @_env ||= ENV["RACK_ENV"] || "development"
    end

    def self.routes
      # Check out https://github.com/joshbuddy/http_router for more information on HttpRouter
      @_routes ||= HttpRouter.new do
        add("/").to(HomeAction)
        add("/stream").to(StreamAction)
      end
    end

    # Initialize the application
    def self.initialize!
      Ohm.connect( :url => "redis://redistogo:c2c3b31a37eb49b65ca6d3dbb6aa09d2@stingfish.redistogo.com:9355/" )
    end

  end
end

Bundler.require(:default, Stream::Application.env)

class HomeAction < Cramp::Action
  def start
    @@template = Erubis::Eruby.new(File.read("index.erb"))
    render @@template.result(binding)
    finish
  end
end

class StreamAction < Cramp::Action
  self.transport = :sse
  on_start :send_tweet
  periodic_timer :send_tweet, :every => 1

  def send_tweet
    data = Ohm.redis.spop( "tweet:happy" )
    screen_name = data.split( /,/ )[0].gsub( /^\[|"/, "" )
    render data
  end
end

