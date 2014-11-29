jQuery ->
  form_hooks()

reverse_locality = (locality) ->
  if locality == 'remote'
    'local'
  else if locality == 'local'
    'remote'

valid_locality = (locality) ->
  not not reverse_locality(locality)


form_hooks = ->
  return unless $('form#new_repository_file')
  $('input[name="repository_file[file_upload_type]"]:radio').on 'click', (e) ->
    type = $(this).val()
    if valid_locality type
      $("#group-file_upload_#{type}").show()
      $("#group-file_upload_#{reverse_locality type}").hide()
