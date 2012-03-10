$(function() {
  var permissionList = $(".permissionList");

  // Tipsy tooltip
  permissionList.find("button.help")
  .tipsy({gravity: 'w'})
  .click(function(){
    permissionList.find("input.autocomplete").focus();
  });

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
      var list = permissionList.find("ul");

      $.post(permissionList.data('uri'), {'team_user[user_id]' : ui.item.id}, function(data) {
        data = $(data)
        list.append(data);
        data.effect("highlight", {}, 1500);
      });

      $(this).val('');
      return false;
    }
  });

  // Never submit the autocompletion form
  permissionList.on("submit", "form.autocomplete", function(event) {
    event.preventDefault();
  });
  
  // User removal succeeded
  permissionList.on("ajax:success", "a[data-method=delete]", function() {
    var li = $(this).closest("li");
    li.fadeOut(function() {
      li.remove();
    });
  });
  
  // Show / Hide edit form
  permissionList.on("click", "a[rel=edit]", function(event) {
    event.preventDefault();
    this.blur();
    
    var li   = $(this).closest("li");
    var form = li.find("form");
    if(form.size() == 0){
      // show form
      var random = Math.random().toString().split(".")[1];
      
      // clone template form
      var form = permissionList.find("form.editTemplate").clone().wrap("<div></div>").parent().html();
      form = $(form.replace(/%RANDOM%/g, random))
      .removeClass("editTemplate")
      .addClass("edit")
      .attr("action", li.data('uri'))
      .appendTo(li)
      
      // extend selector for more supported elements
      form.find("input[type=checkbox]").each(function(){
        var name = $(this).attr("name")
        if(!name)
          return;
        
        // change 'model[name]' into 'name'
        var match = name.match(/\w+\[(\w+)\]/)
        if(match)
          name = match[1]
        
        var value = li.data(name);
        var tagName = this.tagName.toLowerCase();
        var type = tagName=='input' ? this.type.toLowerCase() : '';
        
        if(type=='checkbox'){
          this.checked = value=='1'
        }
        // add here support for other input types, when needed
      });
    }else{
      // hide form
      form.remove();
    }
  });
  
  // User removal succeeded
  permissionList.on("ajax:success", "ul", function(event, data) {
    var target = $(event.target)
    var li = target.closest("li");
    li.replaceWith(data);
  });
  
  
  // AJAX Actions failed
  permissionList.on("ajax:error", function(xhr, status, error) {
    alert(status.responseText);
  });
});
