$(function(){
  var userList = $(".userList");
  
  // Never submit the autocompletion form
  userList.on("submit", "form", function(){
    return false;
  })
  
  // Adding users by autocomplete
  userList.on("autocompleteselect", "input.autocomplete", function(event, ui) {
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
  
  // User removal succeeded
  userList.on("ajax:success", "a[data-method=delete]", function(){
    var li = $(this).closest("li");
    li.fadeOut(function(){
      li.remove();
    });
  })
  
  // User removal failed
  userList.on("ajax:error", "a[data-method=delete]", function(xhr, status, error) {
    alert(status.responseText);
  });
});