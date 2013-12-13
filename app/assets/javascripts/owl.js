$(document).ready(function() {
	if($(".class-hierachy").length) {
		$(".entities-detail").hide();
	}
});

$("#hierachy").click(function() {
	$(this).addClass("btn-primary");
	$('#detail-page').removeClass("btn-primary");
	$(".class-hierachy").show();
	$(".entities-detail").hide();
});

$("#detail-page").click(function() {
	$(this).addClass("btn-primary");
	$('#hierachy').removeClass("btn-primary");
	$(".class-hierachy").hide();
	$(".entities-detail").show();
});
