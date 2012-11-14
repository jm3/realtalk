# rename this file to credentials.sh,
# replace the dummy values, and run:
# source credentials.sh

# twitter oauth creds:
export OAUTH_KEY=AAA
export OAUTH_SECRET=BBB
export OAUTH_ACCESS_TOKEN=CCC
export OAUTH_TOKEN_SECRET=DDD

# this will be auto-created for you after running "heroku create"
# and adding the Redis-to-Go Heroku AddOn to your project:
# uncomment next line if using redistogo:
# export REDIS_URL="redis://redistogo:REPLACE_WITH_PROD_REDIS_URL/"

# be sneaky
export RACK_SESSION_SECRET="whatever-something-random-here"

# mirror the vars in Heroku's remote env
# uncomment this block if using heroku
# heroku config:add \
#   REDIS_URL=$REDIS_URL \
#   RACK_SESSION_SECRET=$RACK_SESSION_SECRET \
#   OAUTH_KEY=$OAUTH_KEY \
#   OAUTH_SECRET=$OAUTH_SECRET \
#   OAUTH_ACCESS_TOKEN=$OAUTH_ACCESS_TOKEN \
#   OAUTH_TOKEN_SECRET=$OAUTH_TOKEN_SECRET

