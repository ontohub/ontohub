require 'test_helper'

class GraphDataFetcherTest < ActiveSupport::TestCase

  context 'determine the mapping class correctly' do

    setup do
      @source = FactoryGirl.create(:logic)
      @fetcher = GraphDataFetcher.new(center: @source)
    end

    should 'produce a LogicMapping source in case of a logic' do
      source = @fetcher.determine_source(@source.class)
      assert_equal LogicMapping, source
    end

    should 'raise UnknownMapping error on unknown class' do
      assert_raises GraphDataFetcher::UnknownMapping do
        @fetcher.determine_source(Object)
      end
    end

  end

  context 'query for mapping-type correctly' do

    should 'produce the correct type on known mapping' do
      assert_equal :Link, GraphDataFetcher.link_for(Ontology)
      assert_equal :LogicMapping, GraphDataFetcher.link_for(Logic)
    end

    should 'raise the correct error on unknown mapping' do
      assert_raises GraphDataFetcher::UnknownMapping do
        GraphDataFetcher.link_for(LogicMapping)
      end
    end

  end

  context 'logic specific tests' do

    setup do
      @user = FactoryGirl.create :user
      @source = FactoryGirl.create(:logic, user: @user)
      @target = FactoryGirl.create(:logic, user: @user)
      @mapping = FactoryGirl.create(:logic_mapping,
                                    source: @source,
                                    target: @target,
                                    user: @user)
      @fetcher = GraphDataFetcher.new(center: @source)
      @nodes, @edges = @fetcher.fetch
    end

    context 'valid request' do

      should 'include source in the nodes list' do
        assert_includes @nodes, @source
      end

      should 'include target in the nodes list' do
        assert_includes @nodes, @target
      end

      should 'edges should include the mapping' do
        assert_includes @edges, @mapping
      end

    end

  end

  context 'ontology specific tests' do

    setup do
      @source = FactoryGirl.create(:single_ontology, state: 'done')
      @target = FactoryGirl.create(:single_ontology, state: 'done')
      @mapping = FactoryGirl.create(:link,
                                    source: @source,
                                    target: @target,
                                    ontology: @source)
      @fetcher = GraphDataFetcher.new(center: @source)
      @nodes, @edges = @fetcher.fetch
    end

    context 'valid request' do

      should 'include source in the nodes list' do
        assert_includes @nodes, @source
      end

      should 'include target in the nodes list' do
        assert_includes @nodes, @target
      end

      should 'edges should include the mapping' do
        assert_includes @edges, @mapping
      end

    end

  end

  context 'distributed ontology specific tests' do

    setup do
      @distributed = FactoryGirl.create(:linked_distributed_ontology)
      @links = Link.where(ontology_id: @distributed.id)
      @fetcher = GraphDataFetcher.new(center: @distributed)
      @nodes, @edges = @fetcher.fetch
    end

    context 'with valid request:' do

      should 'include all children in the node list' do
        children = @distributed.children.map{|o| Ontology.find(o.id)}
        children.each do |child|
          assert_includes @nodes, child
        end
      end

      should 'include all links defined by the DO in the edge list' do
        @links.each do |link|
          assert @edges.include?(link)
        end
      end

    end

  end

end
