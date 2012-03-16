$.widget("ui.permissionList", {

  _create : function() {
    var self = this, element = this.element;
    
    this.association = element.data('association')
    this.scope       = element.data('scope').split(",");
    this.polymorphic = element.data('polymorphic')
    this.model       = this.toUnderscore(element.data('model'));
    
    // Attach Autocomplete to inputs
    this.autocomplete = element.find("input.autocomplete")
    this.autocomplete.autocomplete({
      minLength : 3,
      source : function(request, response) {
        return self.autocompleteSource(request, response);
      },
      select : function(event, ui) {
        return self.autocompleteSelect(event, ui);
      },
    }).data( "autocomplete")._renderItem = this.autocompleteIcon;

    // Never submit the autocompletion form
    element.on("submit", "form.add", function(event) {
      event.preventDefault();
    });
    
    // Removal of permissions
    element.on("click", "a[rel=delete]", function() {
      var li = $(this).closest("li");
      
      if(!confirm("really delete?"))
        return;
      
      $.ajax({
        type: 'POST',
        url: li.data('uri'),
        data: {_method: 'delete'},
        success: function(){
          li.fadeOut(function() {
            li.remove();
          })
        },
        error: function(xhr, status, error){
          li.trigger('ajax:error', [xhr, status, error]);
        }
      });
    });
    
    // Show / Hide edit form
    element.on("click", "a[rel=edit]", function(event) {
      event.preventDefault();
      this.blur();

      var li = $(this).closest("li");
      var form = li.find("form");
      if(form.size() == 0) {
        // show form
        var random = Math.random().toString().split(".")[1];

        // clone template form
        var form = element.find("form.editTemplate").clone().wrap("<div></div>").parent().html();
        form = $(form.replace(/%RANDOM%/g, random)).removeClass("editTemplate").addClass("edit").attr("action", li.data('uri')).appendTo(li)

        // extend selector for more supported elements
        form.find("input[type=checkbox], select").each(function() {
          var name = $(this).attr("name")
          if(!name)
            return;

          // change 'model[name]' into 'name'
          var match = name.match(/\w+\[(\w+)\]/)
          if(match)
            name = match[1]
          var value = li.data(name);
          var type = this.tagName.toLowerCase();
          if(type=='input')
            var type = this.type.toLowerCase();
          
          switch(type){
            case 'checkbox':
              this.checked = value == '1'
              break;
            case 'select':
              $(this).val(value);
              break;
          // add here support for other input types, when needed
          }
        });
      } else {
        // hide form
        form.remove();
      }
    });
    
    // Permission removal succeeded
    element.on("ajax:success", "ul", function(event, data) {
      var target = $(event.target)
      var li = target.closest("li");
      li.replaceWith(data);
    });
    
    // AJAX Actions failed
    element.on("ajax:error", function(xhr, status, error) {
      alert(status.responseText);
    });
  },
  // collects elements from list for exclusion
  excludeMap : function() {
    var self = this;
    var map = {}

    this.element.find("ul").children().each(function() {
      var $this = $(this);
      var type = $this.data('type') || self.scope[0];
      var key = "exclude[" + type + "]"
      var id = $this.data('id');
      if(map[key])
        map[key] += "," + id;
      else
        map[key] = id;
    });
    return map;
  },
  // source for autcomplete
  autocompleteSource : function(request, response) {

    var params = $.extend(this.excludeMap(), {
      term : request.term,
      scope : this.scope.join(",")
    });

    $.ajax({
      url : '/autocomplete',
      data : params,
      success : function(data) {
        response(data)
      }
    })
  },
  
  // autocomplete select-handler
  autocompleteSelect : function(event, ui) {
    var input = $(this);
    var list = this.element.find("ul");
    var params = {}
    
    params[this.model + '[' + this.association + '_id]'] = ui.item.id;
    if(this.polymorphic){
      params[this.model + '[' + this.association + '_type]'] = ui.item.type;
    }
    
    // Create the permission
    $.post(this.element.data('uri'), params, function(data) {
      data = $(data).hide();
      list.append(data);
      data.fadeIn('slow');
    });

    this.autocomplete.val('');
    return false;
  },
  
  autocompleteIcon: function( ul, item ) {
    return $( "<li></li>" )
      .data( "item.autocomplete", item )
      .append( "<a data-type='"+item.type+"'>" + item.label +  "</a>" )
      .appendTo( ul );
  },
  
  // camelCase to under_score
  toUnderscore: function(value){
    value = value.replace(/([A-Z])/g, function($1){return "_"+$1.toLowerCase();});
    if(value.indexOf('_')===0)
      value = value.substr(1)
    return value;
  }
  
});
