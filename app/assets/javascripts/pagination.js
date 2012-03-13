$(function(){
  $(".pagination select").change(function(){
    this.form.submit();
  });
})
