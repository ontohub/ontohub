require 'test_helper'

class GraphDataFetcherTest < ActiveSupport::TestCase

  context 'determine the mapping class correctly' do

    setup do
      user = FactoryGirl.create :user
      @source = FactoryGirl.create(:logic, user: user)
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

end
