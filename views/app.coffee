# subscribe to events
es = new EventSource "/stream"

# add tweet to page
es.onmessage = (e) ->
  tweet = jQuery.parseJSON e.data
  $("#tweets").prepend "
    <div class='tweet' data-screen-name='#{tweet[0]}'>
      <a target='tweet' href='http://twitter.com/#{tweet[0]}'>
        <div class='icon' style='background-image:url(http://img.tweetimag.es/i/#{tweet[0]}_n);' />
      </a>
      <span class='text'>
        #{tweet[1]}
      </span>
    </div>
    "

# update search query on the fly
init_ui = () ->
  $("#config").submit () ->
    qs = $(this).serialize()
    $.getJSON "/tracker?" + qs, (data) ->
      # TODO handle errors
    return false

$(document).ready () ->
  init_ui()

SECONDS_TILL_CLEANUP = 30
prune_dom = () ->
  t = $("#tweets")
  t.children().slice( parseInt( t.children().size() / 2), (t.children().size())).replaceWith( "" )
  setTimeout("prune_dom()", SECONDS_TILL_CLEANUP * 1000)

window.setTimeout(prune_dom, SECONDS_TILL_CLEANUP * 1000, true)
