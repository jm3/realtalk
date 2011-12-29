require "bundler"
require "rubygems"
require "fileutils"
require "tilt"

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
        add("/query/current").to(QueryCurrentAction)
        add("/users/count").to(UsersCountAction)
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
    render Tilt.new( "views/index.haml" ).render( context = nil, :user_agent => request.env["HTTP_USER_AGENT"] )
    finish
  end
end

class StreamAction < Cramp::Action
  self.transport = :sse
  use_fiber_pool :size => 1024 
  periodic_timer :stream_new_event, :every => 1
  on_start :user_connected
  on_finish :user_left
  @@users = Set.new

  def user_connected
    @@users << self
    Ohm.redis.set( "cfg:users:count", @@users.size )
    puts "user ##{@@users.size} connected to stream"
  end

  def user_left
    @@users.delete self
    Ohm.redis.set( "cfg:users:count", @@users.size )
    puts "user left (#{@@users.size} remaining)"
    finish
  end

  def stream_new_event
    data = Ohm.redis.spop( "tweet:#{Ohm.redis.get("cfg:track:kind")}:#{Ohm.redis.get("cfg:track:query")}" )
    if data
      @@users.each { |u| u.render data }
    end
  end
end

class QueryCurrentAction < Cramp::Action
  def start
    render "{\"query\": \"#{ Ohm.redis.get( "cfg:track:query" ) }\" }"
    finish
  end
end

class UsersCountAction < Cramp::Action
  def start
    render "{\"users_count\": \"#{ Ohm.redis.get( "cfg:users:count" ) }\" }"
    finish
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
        puts "switched focus to track tweets about #{query}!"
        Ohm.redis.set( "cfg:track:kind", kind)
        Ohm.redis.set( "cfg:track:query", query)
        @status = "success"
      end
    end

    new_kind = Ohm.redis.get("cfg:track:kind")
    new_query = Ohm.redis.get("cfg:track:query")

    render "{\"tracker_created\": \"#{@status}\", \"query\": \"#{new_query}\",\"kind\": \"#{new_kind}\" }"
    finish
  end
end

# set up coffeescript compiler
Barista.configure do |b|
  b.app_root    = Stream::Application.root
  b.root        = File.join(Stream::Application.root, "views")
  b.output_root = File.join(Stream::Application.root, "tmp")
  b.setup_defaults
end

