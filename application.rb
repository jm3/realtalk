require "bundler"
require "rubygems"

module Stream
  class Application

    def self.root(path = nil)
      @_root ||= File.expand_path(File.dirname(__FILE__))
      path ? File.join(@_root, path.to_s) : @_root
    end

    def self.env
      @_env ||= ENV['RACK_ENV'] || 'development'
    end

    def self.routes
      @_routes ||= eval(File.read('./config/routes.rb'))
    end

    # Initialize the application
    def self.initialize!
      Ohm.connect( :url => "redis://redistogo:c2c3b31a37eb49b65ca6d3dbb6aa09d2@stingfish.redistogo.com:9355/" )
    end

  end
end

Bundler.require(:default, Stream::Application.env)

# Preload application classes
Dir['./app/**/*.rb'].each {|f| require f}
