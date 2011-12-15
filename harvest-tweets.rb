#!/usr/bin/env ruby
# encoding: UTF-8

require "ohm"  
require "tweetstream"  
require "yajl/json_gem"

Ohm.connect( :url => "redis://redistogo:c2c3b31a37eb49b65ca6d3dbb6aa09d2@stingfish.redistogo.com:9355/" )

TweetStream.configure do |config|
  config.consumer_key       = Ohm.redis.get "cfg:consumer_key"
  config.consumer_secret    = Ohm.redis.get "cfg:consumer_secret"
  config.oauth_token        = Ohm.redis.get "cfg:oauth_token"
  config.oauth_token_secret = Ohm.redis.get "cfg:token_secret"

  config.auth_method = :oauth
  config.parser   = :yajl
end

term = ARGV[0] || "happy"
@tracker = TweetStream::Client.new.track( term ) do |status|
  Ohm.redis.sadd "tweet:#{term}", [status.user.screen_name, status.text].to_json
end

