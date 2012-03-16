// Tipsy tooltip
$(function(){
  $("button.help").tipsy({
    gravity : 'w'
  }).click(function(event) {
    event.preventDefault();
    $(this).closest("form").find("input:visible").first().focus();
  });
})