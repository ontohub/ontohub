$(function(){
  // Attach Autocomplete to inputs
  $("input.autocomplete").each(function(){
    $(this).autocomplete({
      source: "/autocomplete?scope=" + $(this).data('scope'),
      minLength: 3
    })
  })
  
})
