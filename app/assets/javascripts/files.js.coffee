filename_input = 'input#repository_file_target_filename'
remote_file_input = 'input#repository_file_remote_file_iri'
current_filename = null

jQuery ->
  form_hooks()
  remote_iri_hook()

reverse_locality = (locality) ->
  if locality == 'remote'
    'local'
  else if locality == 'local'
    'remote'

valid_locality = (locality) ->
  not not reverse_locality(locality)

determine_filetype = (iri, callback) ->
  payload = iri: iri
  $.post "/filetypes/", payload, callback, 'json'

determine_filename = (callback) ->
  iri = $(remote_file_input).val()
  if iri.length
    result = iri.match(/\/([^/]+)(\?.*)?$/)
    callback(result[1], iri) if result

has_fileextension = (filename) ->
  filename.split('.').length > 1

eligible_for_filename_suggestion = ->
  $(filename_input).val().length == 0 or
    current_filename == $(filename_input).val()

form_hooks = ->
  return unless $('form#new_repository_file')
  $('input[name="repository_file[file_upload_type]"]:radio').on 'click', (e) ->
    type = $(this).val()
    if valid_locality type
      $("#group-file_upload_#{type}").show()
      $("#group-file_upload_#{reverse_locality type}").hide()

remote_iri_hook = ->
  $(remote_file_input).on 'keyup', (e) ->
    determine_filename (filename, iri) ->
      if not has_fileextension(filename) and eligible_for_filename_suggestion()
        determine_filetype iri, (filetype) ->
          suggested_filename = "#{filename}#{filetype.extension}"
          $(filename_input).val(suggested_filename)
          current_filename = suggested_filename
