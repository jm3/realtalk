# REALTALK

## Stream tweets to browsers using Server-Sent Events, Cramp, and Redis.

![Greetings Programs](http://f.cl.ly/items/302g1C2d3K0c2x3c2y1V/Screen%20Shot%202011-12-15%20at%2011.18.26%20AM.png)

### Features:

* supports with Heroku and Foreman
* for roadmap, see the Issues tab

### Usage:

    bundle
    bundle exec foreman start

### to make sure both workers are running on heroku:

    heroku scale web=1 tweet_harvester+1

