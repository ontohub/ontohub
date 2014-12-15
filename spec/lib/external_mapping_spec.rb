require 'spec_helper'
include ExternalMapping
describe ExternalMapping do

  context 'external_wiki_mappings' do

    before do
      @mappings = Ontohub::Application.config.external_url_mapping["wiki"]
      @root = @mappings["root"]
    end

    it 'should mapping to wiki root for non existing actions' do
      mapping = @root+(get_mapping_for @mappings, "controller", "graphs", "show")
      mapping.should == @root
    end

    it 'should mapping to specific wiki page' do
      mapping = @root+(get_mapping_for @mappings, "controller", "graphs", "index")
      mapping.should == @root+"show_graph"
    end
  end
end
