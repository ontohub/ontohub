require 'test_helper'

class OntologyTypeTest < ActiveSupport::TestCase

  context 'Migrations' do
    %w( name description documentation ).each do |column|
      should have_db_column(column).of_type(:text)
    end
    should have_db_index(:name).unique(true)
  end
    
  context 'Validations' do
    ['http://example.com/', 'https://example.com/', 'file://path/to/file'].each do |val|
      should allow_value(val).for :documentation
    end
  end

  [nil, '', 'fooo'].each do |val|
    should_not allow_value(val).for :documentation
  end
  
end
