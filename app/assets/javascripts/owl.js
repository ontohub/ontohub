$(document).ready(function() {
	if($("#class-hierarchy").length && $("#class-hierarchy").is(':visible')) {
		$(".symbols-detail").hide();
	}
});

$("#hierarchy").click(function() {
	$(this).addClass("btn-primary");
	$('#detail-page').removeClass("btn-primary");
	$("#class-hierarchy").removeClass("hide");
	$("#class-hierarchy").show();
	$(".symbols-detail").hide();
});

$("#detail-page").click(function() {
	$(this).addClass("btn-primary");
	$('#hierarchy').removeClass("btn-primary");
	$("#class-hierarchy").hide();
	$(".symbols-detail").show();
});
