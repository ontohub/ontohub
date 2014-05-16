require 'test_helper'

class OntologyVersionsControllerTest < ActionController::TestCase

  should_map_nested_resources :repositories, :ontologies, :ontology_versions,
    :as     => 'versions',
    :except => [:show, :edit, :update, :destroy]

  context 'OntologyVersion of a DistributedOntology' do
    setup do
      @user = FactoryGirl.create :user
      @ontology = FactoryGirl.create :distributed_ontology
      @ontology.import_xml_from_file fixture_file('test2.xml'), fixture_file('test2.pp.xml'), @user
      @version  = FactoryGirl.create :ontology_version, ontology: @ontology
      @ontology.reload
      @ontology_child = @ontology.children.first
      @repository = @ontology.repository
    end

    context 'on GET to index of a child' do
      setup do
        get :index, repository_id: @repository.to_param, ontology_id: @ontology_child.to_param
      end

      should 'assign the parents versions' do
        assert_equal [@version], assigns(:versions)
      end
    end
  end

  context 'OntologyVersion Instance' do
    setup do
      @version  = FactoryGirl.create :ontology_version_with_file
      @ontology = @version.ontology
      @repository = @ontology.repository
    end

    context 'on GET to index' do
      setup do
        get :index, repository_id: @repository.to_param, ontology_id: @ontology.to_param
      end

      should respond_with :success

      context 'for a single ontology' do
        should 'assign the right versions' do
          assert assigns(:versions)
        end
      end
    end
  end

end
