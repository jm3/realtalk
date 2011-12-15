class HomeAction < Cramp::Action
  def start
    @@template = Erubis::Eruby.new(File.read('index.erb'))
    render @@template.result(binding)
    finish
  end
end

class StreamAction < Cramp::Action
  self.transport = :sse

  on_start :send_latest_time
  periodic_timer :send_latest_time, :every => 2

  def send_latest_time
    data = {'time' => Time.now.to_i}.to_json
    render data
  end
end

