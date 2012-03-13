$.fn.relatizeTimestamps = function() {
  $(this).find(".timestamp").relatizeDate({
    defaultLanguage: 'en',
    titleize: true
  });
  return this;
};

$(function(){
  // relatize all timestamps on load
  $("body").relatizeTimestamps();
})