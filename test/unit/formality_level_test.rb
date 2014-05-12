require 'test_helper'

class FormalityLevelTest < ActiveSupport::TestCase

  context 'Migrations' do
    %w( name description ).each do |column|
      should have_db_column(column).of_type(:text)
    end
    should have_db_index(:name).unique(true)
  end

  context 'Validations' do

    context 'when no name is taken' do
      should allow_value('foo').for :name
    end

    context "when 'foo' is already taken" do
      setup do
        FormalityLevel.create!(:name => 'foo')
      end
      should_not allow_value('foo').for :name
    end

    context 'when FormalityLevel without name is to be saved' do
      should 'raise error' do
        assert_raise ActiveRecord::RecordInvalid do
          FormalityLevel.create!
        end
      end
    end

  end

end
