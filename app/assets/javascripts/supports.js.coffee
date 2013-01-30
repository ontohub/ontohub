$ ->
  $(".languages.autocomplete").autocomplete({
     source: '/languages/search'
     select: ( event, ui ) ->
      temp = $(event.target).val ui.item.value 
      $('.add').submit()
  });
$ ->
  $(".logics.autocomplete").autocomplete({
     source: '/logics/search'
     select: ( event, ui ) ->
      $(event.target).val(ui.item.value)
      $('.add').submit()
  });
