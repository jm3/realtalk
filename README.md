# REALTALK

## Stream tweets to browsers using Server-Sent Events, Cramp, and Redis.

![Greetings Programs](http://f.cl.ly/items/302g1C2d3K0c2x3c2y1V/Screen%20Shot%202011-12-15%20at%2011.18.26%20AM.png)

### Features:

* runs (out of the box) on Heroku using [Foreman](http://ddollar.github.com/foreman/), [Redis](http://redis.io/), and [Cramp](http://cramp.in)

### Usage:

    # install gems
    bundle

    # fill in credentials file, then...
    # store credentials for the app to read
    bundle exec sh credentials.sh

    # start the process group
    bundle exec foreman start

    # change heroku default of 0 workers to 1:
    heroku scale web=1 tweet_harvester+1

