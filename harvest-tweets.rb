#!/usr/bin/env ruby
# encoding: UTF-8

require "ohm"  
require "tweetstream"  
require "yajl/json_gem"

if ! ENV["OAUTH_KEY"]
  puts <<-eos
   ###############################################
   # warning: no OAuth Key set in environment;   #
   # did you forget to: source credentials.sh?   #
   ###############################################
  eos
  exit
end

DEFAULT_KIND    = "keyword"
DEFAULT_KEYWORD = "happy"

Ohm.connect( :url => ENV["REDIS_URL"] )

TweetStream.configure do |config|
  config.consumer_key       = ENV["OAUTH_KEY"]
  config.consumer_secret    = ENV["OAUTH_SECRET"]
  config.oauth_token        = ENV["OAUTH_ACCESS_TOKEN"]
  config.oauth_token_secret = ENV["OAUTH_TOKEN_SECRET"]

  config.auth_method = :oauth
  config.parser      = :yajl
end

kind  = Ohm.redis.get("cfg:track:kind")  || ARGV[0] || DEFAULT_KIND
query = Ohm.redis.get("cfg:track:query") || ARGV[1] || DEFAULT_KEYWORD

if query.empty?
  puts "ERROR: no term to track"
  exit
end

Ohm.redis.set("cfg:track:kind", kind)
Ohm.redis.set("cfg:track:query", query)

loop do
  TweetStream::Client.new.track( query ) do |status, client|
    # if we've received a new tracking request, immediately bail & reload
    client.stop if Ohm.redis.get( "cfg:track:kind" ) != kind or Ohm.redis.get( "cfg:track:query" ) != query

    if Ohm.redis.scard( "tweet:#{kind}:#{query}" ) > 1000
      Ohm.redis.del( "tweet:#{kind}:#{query}" )
    end

    condensed_metadata = {
      :text                   => status.text,
      :screen_name            => status.user.screen_name,
      :name                   => status.user.name,
      :location               => status.user.location,
      :lang                   => status.user.lang,
      :protected              => status.user.protected,
      :id_str                 => status.id_str,
      :in_reply_to_user_id    => status.in_reply_to_user_id,
      :in_reply_to_status_id  => status.in_reply_to_status_id,
      :hashtags               => status.entities.hashtags,
      :urls                   => status.entities.urls,
      :user_mentions          => status.entities.user_mentions,
    }

    Ohm.redis.sadd "tweet:#{kind}:#{query}", condensed_metadata.to_json
  end

  kind  = Ohm.redis.get("cfg:track:kind")  || DEFAULT_KIND
  query = Ohm.redis.get("cfg:track:query") || DEFAULT_KEYWORD
end

