$(function() {
	$.jstree._themes = "/assets/jstree-themes/";
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
	container = $(".selector");
	uri = container.data("uri");

	container.bind("loaded.jstree", function (event, data) {
		$.getJSON(uri, function (data) {
			$.each(data, function() {
				container.jstree("check_node", "#" + this.id);
			})
		})
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
