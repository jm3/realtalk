require "./application"
Stream::Application.initialize!

# Development middlewares
if Stream::Application.env == "development"
  use AsyncRack::CommonLogger

  # Enable code reloading on every request
  use Rack::Reloader, 0
end

# Serve static assets
use Rack::Static,
  :urls => ["/images", "/javascripts", "/stylesheets"],
  :root => Stream::Application.root(:public)

use Rack::Session::Cookie, 
  :key => "rack.session",
  :domain => "realtalk.herokuapp.com",
  :path => "/",
  :expire_after => (30 * 24 * 60 * 60),
  :secret => ENV["RACK_SESSION_SECRET"]

run Stream::Application.routes
