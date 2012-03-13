$(".ui-tabs.static")
.on("mouseover", "li", function(){
  $(this).addClass("ui-state-hover")
})
.on("mouseout", "li", function(){
  $(this).removeClass("ui-state-hover")
});
