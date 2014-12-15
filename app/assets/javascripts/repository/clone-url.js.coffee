
# Select Clone URL on click
$(".clone-url").on 'click', ->
  @select()

window.activate_clone_url = (fragment) ->
  activate = (clone_type) ->
    $('p.clone_url_block').each (index, el) ->
      selection = $(el)
      if selection.data('clone') == clone_type
        selection.show()
      else
        selection.hide()
  clone_type = fragment
  clone_type = 'git' if !fragment.length
  activate(clone_type)

jQuery ->
  activate_clone_url location.hash.substring(1)
  $('a.clone_method_link').on 'click', ->
    activate_clone_url $(this).data('clone')
