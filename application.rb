require "bundler"
require "rubygems"
require "fileutils"

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
  periodic_timer :stream_new_event, :every => 1
  on_start :user_connected
  on_finish :user_left
  @@users = Set.new

  def user_connected
    @@users << self
    puts "user ##{@@users.size} connected"
  end

  def user_left
    @@users.delete self
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

class ConfigAction < Cramp::Action
  def start

    kind = params[:kind]
    query = params[:query]
    @status = "noop"

    case kind
    when "hashtag", "keyword", "screen_name"
      if query and (! query.empty?)
        puts "now tracking tweets about #{query}!"
        Ohm.redis.set( "cfg:track:kind", kind)
        Ohm.redis.set( "cfg:track:query", query)
        @status = "success"
      end
    else
      puts "Now you're just making shit up!"
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

