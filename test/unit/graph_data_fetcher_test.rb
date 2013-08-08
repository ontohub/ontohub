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

end
