class HomeAction < Cramp::Action
  def start
    @@template = Erubis::Eruby.new(File.read('index.erb'))
    render @@template.result(binding)
    finish
  end
end

class StreamAction < Cramp::Action
  self.transport = :sse
  on_start :send_tweet
  periodic_timer :send_tweet, :every => 1

  def send_tweet
    data = Ohm.redis.spop( "tweet:happy" )
    render data
  end
end

