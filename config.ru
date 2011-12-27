require "./application"
Stream::Application.initialize!

  if Stream::Application.env == "development"
    use AsyncRack::CommonLogger

    use Rack::Reloader, 0 # reload code on every request
  end

# automatically serve coffeescript
use Barista::Server::Proxy

# Serve static assets
use Rack::Static,
  :urls => ["/images", "/stylesheets"],
  :root => Stream::Application.root(:public)

# serve compiled js from tmp because heroku hates writeable fs
use Rack::Static,
  :urls => ["/javascripts"],
  :root => Stream::Application.root(:tmp)

use Rack::Session::Cookie, 
  :key => "rack.session",
  :domain => "realtalk.herokuapp.com",
  :path => "/",
  :expire_after => (30 * 24 * 60 * 60),
  :secret => ENV["RACK_SESSION_SECRET"]

run Stream::Application.routes
