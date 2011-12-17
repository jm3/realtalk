require "bundler"
require "oauth"
require "oauth/consumer"
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
      @_routes ||= HttpRouter.new do
        add("/").to(HomeAction)
        add("/stream").to(StreamAction)
      end
    end

    # Initialize the application
    def self.initialize!
      Ohm.connect( :url => ENV["REDIS_URL"] )
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
    render data if data
  end
end

