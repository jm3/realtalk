# subscribe to events
es = new EventSource "/stream"

# global state
window.paused = false

# inject tweets into the page as we receive them
es.onmessage = (e) ->
  return if window.paused
  tweet = jQuery.parseJSON e.data

  # pretty-print the HTML to make it somewhat legible
  $("#tweets").prepend "
    <div class='tweet' data-screen-name='#{tweet[0]}'>
      <a target='tweet' href='//twitter.com/#{tweet[0]}'>
        <div class='icon' style='background-image:url(//img.tweetimag.es/i/#{tweet[0]}_n);' />
      </a>
      <span class='text'>#{tweet[1]}</span>
    </div>
    "

# update search query on the fly
init_ui = () ->
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

SECONDS_TILL_CLEANUP = 30

# save a reference to this callback on the global namespace here
# since we'll have exited the block when it's invoked, later.
window.clean_up_DOM = () ->
  t = $("#tweets")
  t.children().slice( parseInt( t.children().size() / 2), (t.children().size())).replaceWith( "" )
  setTimeout("window.clean_up_DOM()", SECONDS_TILL_CLEANUP * 1000)

window.setTimeout(window.clean_up_DOM, SECONDS_TILL_CLEANUP * 1000, true)
