$(function() {
  
  /**
   * Copy Source URI from version into URI from ontology
   */
  var uriField = $("#ontology_uri")
  var sourceUriField = $("#ontology_versions_attributes_0_source_url")
  var automatic = uriField.val() == sourceUriField.val();
  
  sourceUriField.change(function(){
    if(automatic)
      uriField.val($(this).val());
  });
  
  uriField.change(function(){
    automatic = $(this).val().length == 0;
  });
  
});
