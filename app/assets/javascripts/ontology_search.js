jQuery.ajaxSettings.cache = false;

var search = function(self) {
      return function() {
        $.ajax({
          url: $(self).closest("form").attr("action"),
          type: 'GET',
          data: $(self).closest("form").serialize(),
          success: function(d) {
            if($(".pagination").length) {
              $(".pagination:first").replaceWith($(d).find(".pagination:first"));
            } else {
              $(d).find(".pagination:first").insertBefore($("#search_response"));
            }
            $("#search_response").replaceWith($(d).find("#search_response"));
          }
        });
      };
    };

var delay = (function(){
  var timer = 0;
  return function(callback, ms){
    clearTimeout (timer);
    timer = setTimeout(callback, ms);
  };
})();

$(function() {
  $("#query").keyup(function(e) {
    delay(search(this), 200);
  });
  $("#search_form").submit(function(e) {
    e.preventDefault();
    search(this)();
  });
  $("select").change(function(e) {
    search(this)();
  });
});
