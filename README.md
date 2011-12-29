# Realtalk

## Realtime tweet streaming via Server-Sent Events, Cramp, and Redis.

![Greetings Programs](http://f.cl.ly/items/302g1C2d3K0c2x3c2y1V/Screen%20Shot%202011-12-15%20at%2011.18.26%20AM.png)

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

### Usage:

    # install gems
    bundle

    # rename sample.credentials.sh to credentials.sh and fill it in
    source credentials.sh

    # start the process group
    bundle exec foreman start

    # change heroku default of 0 workers to 1:
    heroku scale web=1 tweet_harvester+1

