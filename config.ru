require "./application"
Stream::Application.initialize!

# Development middlewares
if Stream::Application.env == 'development'
  use AsyncRack::CommonLogger

  # Enable code reloading on every request
  use Rack::Reloader, 0
end

# Serve static assets
use Rack::Static, :urls => ["/images", "/javascripts", "/stylesheets"], :root => Stream::Application.root(:public)

run Stream::Application.routes
