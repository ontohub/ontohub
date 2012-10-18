$ ->
  # 
  # Copy Source URL from version into IRI from ontology
  # 
  iriField = $("#ontology_iri")
  sourceIriField = $("#ontology_versions_attributes_0_source_url")
  automatic = iriField.val() is sourceIriField.val()
  sourceIriField.change ->
    iriField.val $(this).val()  if automatic

  iriField.change ->
    automatic = $(this).val().length is 0
