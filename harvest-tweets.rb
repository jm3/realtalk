#!/usr/bin/env ruby
# encoding: UTF-8

require "ohm"  
require "tweetstream"  
require "yajl/json_gem"

Ohm.connect( :url => ENV["REDIS_URL"] )

TweetStream.configure do |config|
  config.consumer_key       = ENV["OAUTH_KEY"]
  config.consumer_secret    = ENV["OAUTH_SECRET"]
  config.oauth_token        = ENV["OAUTH_ACCESS_TOKEN"]
  config.oauth_token_secret = ENV["OAUTH_TOKEN_SECRET"]

  config.auth_method = :oauth
  config.parser   = :yajl
end

term = ARGV[0] || "happy"
@tracker = TweetStream::Client.new.track( term ) do |status|
  if Ohm.redis.scard( "tweet:#{term}" ) > 1000
    Ohm.redis.del( "tweet:#{term}" ) 
  end
  Ohm.redis.sadd "tweet:#{term}", [status.user.screen_name, status.text].to_json
end

