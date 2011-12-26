# subscribe to events
es = new EventSource "/stream"

# inject tweets into the page as we receive them
es.onmessage = (e) ->
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
  $("#config").submit () ->
    qs = $(this).serialize()

    # display feedback to the user that we're now tracking her query
    $.getJSON "/tracker?" + qs, (data) ->
      $(".query").html data.query if data.tracker_created == "success"
    return false

$(document).ready () ->
  init_ui()

SECONDS_TILL_CLEANUP = 30
prune_dom = () ->
  t = $("#tweets")
  t.children().slice( parseInt( t.children().size() / 2), (t.children().size())).replaceWith( "" )
  setTimeout("prune_dom()", SECONDS_TILL_CLEANUP * 1000)

window.setTimeout(prune_dom, SECONDS_TILL_CLEANUP * 1000, true)
