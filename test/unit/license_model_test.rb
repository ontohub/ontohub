require 'test_helper'

class LicenseModelTest < ActiveSupport::TestCase

  context 'Migrations' do
    %w( name description url ).each do |column|
      should have_db_column(column).of_type(:text)
    end
    should have_db_index(:name).unique(true)
  end

  context 'Validations' do

    context 'when no name is taken' do
      should allow_value('foo').for :name
    end

    context 'when name is already taken' do
      setup do
        LicenseModel.create!(:name => 'foo', :url => 'http://foo.com')
      end
      should_not allow_value('foo').for :name
    end

    context 'when LicenseModel without name is to be saved' do
      should 'raise error' do 
        assert_raise ActiveRecord::RecordInvalid do
          LicenseModel.create!
        end
      end
    end

    context 'URL validator' do
      ['http://example.com/', 'https://example.com/', 'file://path/to/file'].each do |val|
        should allow_value(val).for :url
      end
    end

    [nil, '', 'fooo'].each do |val|
      should_not allow_value(val).for :url
    end

  end

end
