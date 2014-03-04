require 'spec_helper'
include ExternalMapping
describe ExternalMapping do

  context 'external_wiki_links' do

    before do
      @mappings = Ontohub::Application.config.external_url_mapping["wiki"]
      @root = @mappings["root"]
    end

    it 'should link to wiki root for non existing actions' do
      link = @root+(get_mapping_for @mappings, "controller", "graphs", "show")
      link.should == @root
    end

    it 'should link to specific wiki page' do
      link = @root+(get_mapping_for @mappings, "controller", "graphs", "index")
      link.should == @root+"show_graph"
    end
  end
end
