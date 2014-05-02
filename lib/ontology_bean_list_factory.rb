require 'json'

class OntologyBeanListFactory

  attr_reader :bean_list

  def initialize
    @bean_list = []
  end

  def add_small_bean(ontology)
    @bean_list.push(make_small_bean(ontology)) if @bean_list.size < 50
  end

  def make_small_bean(ontology)
    {
      name: ontology.name,
      acronym: '',
      language: ontology.language.nil? ? '' : ontology.language.name,
      logic:  ontology.logic.nil? ? '' : ontology.logic.name,
      iri: ontology.iri,
      url: "/repositories/#{ontology.repository.to_param}/ontologies/#{ontology.to_param}",
      description: ontology.description,
      type: make_type_anchor_data(ontology),
      topics: make_topic_anchors_data(ontology),
      projects: make_project_anchors_data(ontology),
      icon: make_icon_image_data(ontology)
    }
  end

  def make_icon_image_data(ontology)
    if !ontology.distributed?
      {
        src: "/assets/icons/single_ontology.svg",
        alt: "Standalone Ontology"
      }
    elsif ontology.heterogeneous?
      {
        src: "/assets/icons/distributed_heterogeneous_ontology.svg",
        alt: "Distributed Heterogeneous Ontology"
      }
    else
      {
        src: "/assets/icons/distributed_homogeneous_ontology.svg",
        alt: "Distributed Homogeneous Ontology"
      }
    end
  end

  def make_topic_anchors_data(ontology)
    ontology.categories.map { |category| {text: category.name, href: "/categories/#{category.id}"} }
  end

  def make_project_anchors_data(ontology)
    ontology.projects.map { |project| {text: project.display_name, href: "/projects/#{project.id}"} }
  end

  def make_type_anchor_data(ontology)
    {text: ontology.ontology_type.name, href: ''} if ontology.ontology_type
  end
end
