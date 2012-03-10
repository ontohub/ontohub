$(function() {
  var permissionList = $(".permissionList");

  // Attach Autocomplete to inputs
  permissionList.find("input.autocomplete").autocomplete({
    minLength : 3,
    source : function(request, response) {
      
      var params = {
        term: request.term,
        scope: this.element.data('scope')
      };
      
      // collect taken elements from list
      permissionList.find("ul").children().each(function(){
        var $this = $(this);
        var key = "exclude["+$this.data('type')+"]"
        var id = $this.data('id');
        if(params[key])
          params[key] += "," + id;
        else
          params[key] = id;
      });
      
      $.ajax({
        url : '/autocomplete',
        data : params,
        success : function(data) {
          response(data)
        }
      });
    },
    select : function(event, ui) {
      var input = $(this);
      var container = $(this).closest(".permissionList");
      var list = container.find("ul");

      $.post(container.data('uri'), {'team_user[user_id]' : ui.item.id}, function(data) {
        list.append(data);
      });

      $(this).val('');
      return false;
    }
  });

  // Never submit the autocompletion form
  permissionList.on("submit", "form", function() {
    return false;
  })
  // User removal succeeded
  permissionList.on("ajax:success", "a[data-method=delete]", function() {
    var li = $(this).closest("li");
    li.fadeOut(function() {
      li.remove();
    });
  })
  // User removal failed
  permissionList.on("ajax:error", "a[data-method=delete]", function(xhr, status, error) {
    alert(status.responseText);
  });
});
