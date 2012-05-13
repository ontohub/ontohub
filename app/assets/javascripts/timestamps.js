$.fn.relatizeTimestamps = function() {
  $(this).find(".timestamp").each(function(){
    var $this = $(this);
    var time = moment($this.text());
    $this.text(time.fromNow()).attr("title", time.format("LLLL"));
  });
  return this;
};

$(function(){
  // relatize all timestamps on load
  $("body").relatizeTimestamps();
})