require 'spec_helper'

describe GraphDataFetcher do
  context 'determine the mapping class correctly' do
    let(:source) { FactoryGirl.create(:logic) }
    let(:fetcher) { GraphDataFetcher.new(center: source) }

    it 'produce a LogicMapping source in case of a logic' do
      expect(fetcher.determine_source(source.class)).
        to eq(LogicMapping)
    end

    it 'raise UnknownMapping error on unknown class' do
      expect { fetcher.determine_source(Object) }.
        to raise_error(GraphDataFetcher::UnknownMapping)
    end
  end

  context 'query for mapping-type correctly' do
    it 'produce the correct type on known mapping (Link)' do
      expect(GraphDataFetcher.link_for(Ontology)).to eq(:Link)
    end

    it 'produce the correct type on known mapping (LogicMapping)' do
      expect(GraphDataFetcher.link_for(Logic)).to eq(:LogicMapping)
    end

    it 'raise the correct error on unknown mapping' do
      expect { GraphDataFetcher.link_for(LogicMapping) }.
        to raise_error(GraphDataFetcher::UnknownMapping)
    end
  end

  context 'logic specific tests' do
    let!(:user) { FactoryGirl.create :user }
    let!(:source) { FactoryGirl.create(:logic, user: user) }
    let!(:target) { FactoryGirl.create(:logic, user: user) }
    let!(:mapping) do
      FactoryGirl.create(:logic_mapping,
        source: source, target: target, user: user)
    end
    let!(:fetcher) { GraphDataFetcher.new(center: source) }
    let!(:nodes) { fetcher.fetch.first }
    let!(:edges) { fetcher.fetch[1] }

    context 'valid request' do
      it 'include source in the nodes list' do
        expect(nodes).to include(source)
      end

      it 'include target in the nodes list' do
        expect(nodes).to include(target)
      end

      it 'edges it include the mapping' do
        expect(edges).to include(mapping)
      end
    end
  end

  context 'ontology specific tests' do
    let!(:source) { FactoryGirl.create(:single_ontology, state: 'done') }
    let!(:target) { FactoryGirl.create(:single_ontology, state: 'done') }
    let!(:mapping) do
      FactoryGirl.create(:link,
        source: source, target: target, ontology: source)
    end
    let!(:fetcher) { GraphDataFetcher.new(center: source) }
    let!(:nodes) { fetcher.fetch.first }
    let!(:edges) { fetcher.fetch[1] }

    context 'valid request' do
      it 'include source in the nodes list' do
        expect(nodes).to include(source)
      end

      it 'include target in the nodes list' do
        expect(nodes).to include(target)
      end

      it 'edges it include the mapping' do
        expect(edges).to include(mapping)
      end
    end
  end

  context 'distributed ontology specific tests with valid request' do
    let!(:distributed) { FactoryGirl.create(:linked_distributed_ontology) }
    let!(:children) { distributed.children.map{|o| Ontology.find(o.id)} }
    let!(:links) { Link.where(ontology_id: distributed.id) }
    let!(:fetcher) { GraphDataFetcher.new(center: distributed) }
    let!(:nodes) { fetcher.fetch.first }
    let!(:edges) { fetcher.fetch[1] }

    it "include all children in the node list" do
      children.each do |child|
        expect(nodes).to include(child)
      end
    end

    it "include all links defined by the DO in the edge list" do
      links.each do |link|
        expect(edges).to include(link)
      end
    end
  end
end
