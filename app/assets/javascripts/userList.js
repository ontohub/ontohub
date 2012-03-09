$(function(){
  // Adding users to userlists
  $(".userList input.autocomplete" ).bind( "autocompleteselect", function(event, ui) {
    var input = $(this);
    var container = $(this).closest(".userList");
    
    $.post(container.data('uri'), {
      'team_user[user_id]': ui.item.id
    },function(data) {
      container.find("ul").append(data);
    });
    
    $(this).val('');
    return false;
  });
  
  // Events on user removals
  $(".userList")
  .on("ajax:success", "a[data-method=delete]", function(){
    var li = $(this).closest("li");
    li.fadeOut(function(){
      li.remove();
    });
  })
  .on("ajax:error", "a[data-method=delete]", function(xhr, status, error) {
    alert(status.responseText);
  });
});