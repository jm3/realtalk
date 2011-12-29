# subscribe to events
es = new EventSource "/stream"

# global state
window.paused = false

# inject tweets into the page as we receive them
es.onmessage = (e) ->
  return if window.paused

  # tweet
  t = jQuery.parseJSON e.data

  # buffer tweets in form for possible CSV save-out later
  $("#buffer").text( "#{t.screen_name}, #{t.text.replace( /,/g, '\,') }\n#{ $("#buffer").text() }" )

  # pretty-print the HTML to make it somewhat legible
  $("#tweets").prepend "
    <div class='tweet' data-screen-name='#{t.screen_name}'>
      <a target='tweet' href='//twitter.com/#!/#{t.screen_name}'>
        <div class='icon' style='background-image:url(//img.tweetimag.es/i/#{t.screen_name}_n);' />
      </a>
      <span class='text'>
        #{t.name}: #{t.text}
        <a class='permalink' target='tweet' href='//twitter.com/#!/#{t.screen_name}/status/#{t.id_str}'>#</a>
      </span>
    </div>
    "

# update search query on the fly
init_ui = () ->

  # show the user what query the current stream is tracking
  # save global ref so we can call it even after we're outta scope
  window.update_query = () ->
    $.getJSON "/query/current", (data) ->
      $(".query").html data.query
      console.log "updating query"

  # on-load, replace the hardcoded query in the DOM with the current one
  update_query()

  # show the user how many users are connected
  update_user_count = () ->
    $.getJSON "/users/count", (data) ->
      n = data.users_count
      if n == "1"
        s = n + " user"
      else
        s = n + " users"
      $(".users_count").html s

  update_user_count()

  # intercept form submit to allow async updates
  form_interceptor = () ->
    qs = $("#config").serialize()
    $.getJSON "/tracker?" + qs, (data) ->
      # if the server responded positively, display feedback to the
      # user that we're now tracking her query
      $(".query").html data.query if data.tracker_created == "success"
    return false

  # let the user press return or hit the button
  $("#config").submit form_interceptor
  $("#submit_btn").click form_interceptor

  # let the user pause the streaming
  $("#pause").click () ->
    $("#pause").text if window.paused then "Pause" else "Resume Streaming"
    $(".pausable").toggle()
    window.paused = !window.paused

$(document).ready () ->
  init_ui()

# timers, in seconds
QUERY_T   = 5
CLEANUP_T = 30

# keep the query header up to date so that as other users change it, 
# our page remains current
window.refresh_query = () ->
  window.update_query()
  setTimeout("window.refresh_query()", QUERY_T * 1000)
window.setTimeout(window.refresh_query, QUERY_T * 1000, true)

# prune tweets when we've displayed "too many" of them so we don't hog 
# too many browser resources for users who leave the app open for weeks
window.clean_up_DOM = () ->
  t = $("#tweets")
  t.children().slice( parseInt( t.children().size() / 2), (t.children().size())).replaceWith( "" )
  setTimeout("window.clean_up_DOM()", CLEANUP_T * 1000)
window.setTimeout(window.clean_up_DOM, CLEANUP_T * 1000, true)

