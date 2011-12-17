# twitter oauth creds:
export OAUTH_KEY=AAA
export OAUTH_SECRET=BBB
export OAUTH_ACCESS_TOKEN=CCC
export OAUTH_TOKEN_SECRET=DDD

# this will be auto-created for you after running "heroku create"
# and adding the Redis-to-Go Heroku AddOn to your project:
export REDIS_URL="redis://redistogo:0xDEADBEEF@bongs.redistogo.com:9355/"

# be sneaky
export RACK_SESSION_SECRET="foo-HUSH"

# mirror the vars in Heroku's remote env
heroku config:add \
  REDIS_URL=$REDIS_URL \
  RACK_SESSION_SECRET=$RACK_SESSION_SECRET \
  OAUTH_KEY=$OAUTH_KEY \
  OAUTH_SECRET=$OAUTH_SECRET \
  OAUTH_ACCESS_TOKEN=$OAUTH_ACCESS_TOKEN \
  OAUTH_TOKEN_SECRET=$OAUTH_TOKEN_SECRET

