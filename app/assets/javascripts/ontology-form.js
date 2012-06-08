$(function() {
  
  /**
   * Copy Source URL from version into IRI from ontology
   */
  var iriField = $("#ontology_iri")
  var sourceIriField = $("#ontology_versions_attributes_0_source_url")
  var automatic = iriField.val() == sourceIriField.val();
  
  sourceIriField.change(function(){
    if(automatic)
      iriField.val($(this).val());
  });
  
  iriField.change(function(){
    automatic = $(this).val().length == 0;
  });
  
});
