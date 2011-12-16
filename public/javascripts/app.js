/* update on event receipt: */
var es = new EventSource("/stream");

/* add tweet to page */
es.onmessage = function(e) { 
  var tweet = jQuery.parseJSON( e.data );
  $("#tweets").prepend("<div class='tweet' data-screen-name='" + tweet[0] + "'>" 
  + "<a target='tweet' href='http://twitter.com/" + tweet[0] + "'>"
  + "<div class='icon' style='background-image:url(http://img.tweetimag.es/i/" + tweet[0]  +"_n);' />"
  + "</a>"
  + "<span class='text'>"
  + tweet[1]
  + "</span>"
  + "</div>");
};

var SECONDS_TILL_CLEANUP = 30;
function prune_dom() {
  var t = $("#tweets");
  t.children().slice( parseInt( t.children().size() / 2), (t.children().size())).replaceWith( "" );
  // $("#tweets").empty();
  setTimeout("prune_dom()", SECONDS_TILL_CLEANUP * 1000);
}
window.setTimeout(prune_dom, SECONDS_TILL_CLEANUP * 1000, true);
