# Realtalk

by [@jm3](//twitter.com/jm3)

## Realtime tweet streaming to the browser with Server-Sent Events & Redis.

### Requirements:

 * Redis 2.0+ 
 * OAuth keys + secrets from Twitter ([create here](//dev.twitter.com/))

### Usage:

    # install required gems
    bundle

    # add your twitter app keys and redis URL to credentials.sh
    source credentials.sh

    # start collecting tweets and streaming them to browser clients
    bundle exec foreman start

    # if using heroku, increase the number of workers to 1:
    heroku scale web=1 tweet_harvester+1

### Supporting cast:

* Pub/Sub by [Redis](http://redis.io/)
* Asynchronous shenanigans by [Cramp](http://cramp.in)
* Server-Sent Events by [WebSockets](//en.wikipedia.org/wiki/WebSocket)
* Javascript deception by [Coffeescript](//coffeescript.org/)
* Dep management by [The Bundler](//gembundler.com/)
* Process management by [Foreman](http://ddollar.github.com/foreman/)
* HTML element grid by [Bootstrap](//twitter.github.com/bootstrap/)
* Templating by [Haml](//haml-lang.com/)
* Proudly hosted by [Heroku](//heroku.com/)

