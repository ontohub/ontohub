$(function() {
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

$(function() {
	$("#tree").jstree({
		"plugins" : [ "themes", "html_data", "sort", "ui" ],
		"themes": {
			theme: "classic",
			icons: false,
			dots: false
		}
	});
}); 

$("#tree").delegate("a", "click", function(e) {
  document.location.href = this;
});
