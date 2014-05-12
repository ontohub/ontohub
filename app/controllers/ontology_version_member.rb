#
# Must be included in controllers that belong to an
# ontology version.
#
module OntologyVersionMember

  protected

  def ontology
    @ontology ||= Ontology.find(params[:ontology_id])
  end

  def version
    @version ||= ontology.versions.find_by_number!(params[:number])
  end

  def begin_of_association_chain
    version
  end

end
