$(function() {
	// Render last commit, for better performance
	if($(".file-table").length > 0) {
		var table = $(".file-table");
		$.ajax({
			type: "GET",
			url: table.data('ajax-path'),
			dataType: "json",
			data: {
				id: table.data('id'),
				oid: table.data('oid'),
				path: table.data('path')
			}
		}).done(function(list) {
			$.each(list, function(key, value) {
				table.find("tr[data-id="+key+"] td.last-modified").html('<span class="timestamp">'+value.committer_time+'</span>').relatizeTimestamps();
				var html = '<span class="message">'
				html += value.message;
				html += '</span>';
				html += ' ['+value.committer_name+']';
				table.find("tr[data-id="+key+"] td.last-commit").html(html);
			});
			$(".file-table tr td.last-commit .message").truncate({
			    width: 400,
				token: '&hellip;'
			});
		});
	}
});
