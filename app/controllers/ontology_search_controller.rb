# 
# Ontology search endpoints for the GWT search code.
# 
class OntologySearchController < ApplicationController

  respond_to :json

  def keywords
    prefix = params[:prefix] || ''
    if in_repository?
      repository = Repository.find_by_path params[:repository_id]
      respond_with OntologySearch.new.make_repository_keyword_list_json(repository, prefix)
    else
      respond_with OntologySearch.new.make_global_keyword_list_json(prefix)
    end
  end

  def search
    keywords = params[:keywords] || []
    keywords = keywords.map { |keyword| JSON.parse(keyword) }
    page = params[:page] || "0"
    page = page.to_i
    if in_repository?
      repository = Repository.find_by_path params[:repository_id]
      respond_with OntologySearch.new.make_bean_list_json(repository, keywords, page)
    else
      respond_with OntologySearch.new.make_bean_list_json(nil, keywords, page)
    end
  end

  def filters_map    
    types = OntologyType.select([:name, :id]).order(:name).all.map {|type| {"name" => type.name.sub(/Ontology/, "ontologies"), "value" => type.id.to_s} }
    repositories = Repository.select([:name, :id]).order(:name).all.map {|repository| {"name" => "in " + repository.name, "value" => repository.id.to_s} }
    projects = Project.select([:name, :id]).order(:name).all.map {|project| {"name" => "from " + project.name, "value" => project.id.to_s} }
    formalities = FormalityLevel.select([:name, :id]).order(:name).all.map {|formality| {"name" => "in " + formality.name, "value" => formality.id.to_s} }
    licenses = LicenseModel.select([:name, :id]).order(:name).all.map {|license| {"name" => "under " + license.name, "value" => license.id.to_s} }
    tasks = Task.select([:name, :id]).order(:name).all.map {|task| {"name" => "for " + task.name[0..-5].from_titlecase_to_spacedlowercase, "value" => task.id.to_s} }
    filters_map = {
      'OntologyType' => [
        { "name" => 'Ontologies', "value" => nil },
        *types
      ],
      'Repository' => [
        { "name" => 'in all repositories', "value" => nil },
        *repositories
      ],
      'Project' => [
        { "name" => 'from all projects', "value" => nil },
        *projects
      ],
      'FormalityLevel' => [
        { "name" => 'in any formality', "value" => nil },
        *formalities
      ],
      'LicenseModel' => [
        { "name" => 'under any license', "value" => nil },
        *licenses
      ],
      'Task' => [
        { "name" => 'for any purpose', "value" => nil },
        *tasks
      ]
    }
    respond_with JSON.generate(filters_map)
  end

end
