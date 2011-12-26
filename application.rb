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
      @_routes ||= HttpRouter.new do
        add("/").to(HomeAction)
        add("/stream").to(StreamAction)
        add("/tracker").to(ConfigAction)
      end
    end

    def self.initialize!
      Ohm.connect( :url => ENV["REDIS_URL"] )
    end

  end
end

Bundler.require(:default, Stream::Application.env)

class HomeAction < Cramp::Action
  def start
    render Haml::Engine.new(File.read("views/index.haml")).render
    finish
  end
end

class StreamAction < Cramp::Action
  self.transport = :sse
  on_start :send_tweet
  periodic_timer :send_tweet, :every => 1

  def send_tweet
    data = Ohm.redis.spop( "tweet:#{Ohm.redis.get("cfg:track:kind")}:#{Ohm.redis.get("cfg:track:query")}" )
    render data if data
  end
end

class ConfigAction < Cramp::Action
  def start

    kind = params[:kind]
    query = params[:query]
    @status = "noop"

    case kind
    when "hashtag", "keyword", "screen_name"
      if query and (! query.empty?)
        puts "got valid trackable kind #{kind}!"
        Ohm.redis.set( "cfg:track:kind", kind)
        Ohm.redis.set( "cfg:track:query", query)
        @status = "success"
      end
    else
      puts "Now you're just making shit up!"
    end

    new_kind = Ohm.redis.get("cfg:track:kind")
    new_query = Ohm.redis.get("cfg:track:query")

    render "{'tracker_created': '#{@status}', 'query': '#{new_query}','kind': '#{new_kind}' }"
    finish
  end
end

