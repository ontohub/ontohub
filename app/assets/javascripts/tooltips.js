// Tipsy tooltip
$(function(){
  $("button.help").tooltip({
    placement : 'right'
  }).click(function(event) {
    event.preventDefault();
    $(this).closest("form").find("input:visible").first().focus();
  });
  
  $('aside .info .error .help').tooltip({placement:'bottom'});
  
  $("ul.formats a[title]").tooltip({
    placement : 'bottom'
  })
})