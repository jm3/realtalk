#!/usr/bin/env ruby
# encoding: UTF-8

require "ohm"  
Ohm.connect( :url => ENV["REDIS_URL"] )

# positive ints only!
def fmt_num(i)
  return i.to_s.reverse.gsub(/...(?=.)/,'\&,').reverse
end

country_keys = Ohm.redis.keys( "user:country*" )
puts "categorized users into #{country_keys.size} country sets"

lang_keys = Ohm.redis.keys( "user:lang*" )
puts "categorized users into #{lang_keys.size} language sets"

puts

Ohm.redis.keys( "*" ).sort.each do |set|
  next if set.match( /cfg:|user:country|user:lang/ )
  type = Ohm.redis.type( set )
  if type == "set"
    puts "#{set}: #{fmt_num Ohm.redis.scard( set )} (set)"
  else
    puts
    puts set
    puts "top #{set}: #{fmt_num Ohm.redis.zcard( set )} (zset)"
    # redis returns an array of alternating k:v pairs, so we coerce to ruby hash
    top_values = Hash[* Ohm.redis.zrevrange( set, 0, 9, :withscores => true ) ]

    longest_key = top_values.keys.max { |a, b| a.length <=> b.length }
    top_values.each do |key, value|
      printf "  %-#{2 + longest_key.length}s %s\n", key, fmt_num(value)
    end
    puts

  end

  # tweets:hashtags
  # tweets:links
  # tweets:mentions
  # user:country:COUNTRY
  # user:followers
  # user:is_public
  # user:lang:LANG
  # words

end
