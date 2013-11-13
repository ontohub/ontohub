$(function () {
  $.jstree._themes = "assets/jstree-themes/";
  $(".selector").jstree({
    "plugins" : [ "search", "themes", "html_data", "checkbox", "sort", "ui" ],
    "checkbox": {
      real_checkboxes: true,
      real_checkboxes_names: function (n) { return [("category_ids[" + n[0].id  + "]"), 1]; },
      two_state: true
    },
    "themes": {
      theme: "classic",
      icons: false
    }
  });
}); 
