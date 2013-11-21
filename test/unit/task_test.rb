require 'test_helper'

class TaskTest < ActiveSupport::TestCase

  context 'Migrations' do
    %w( name description ).each do |column|
      should have_db_column(column).of_type(:string)
    end
    should have_db_index(:name).unique(true)
  end

  context 'Validations' do

    context 'when no name is taken' do
      should allow_value('foo').for :name
    end

    context 'when name is already taken' do
      setup do
        Task.create!(:name => 'foo')
      end
      should_not allow_value('foo').for :name
    end

    context 'when Task without name is to be saved' do
      should 'raise error' do 
        assert_raise ActiveRecord::RecordInvalid do
          Task.create!
        end
      end
    end

  end

end
