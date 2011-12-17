export REDIS_URL="redis://redistogo:0xDEADBEEF@bongs.redistogo.com:9355/"
export RACK_SESSION_SECRET="foo-HUSH"

heroku config:add \
  REDIS_URL=$REDIS_URL \
  RACK_SESSION_SECRET=$RACK_SESSION_SECRET
