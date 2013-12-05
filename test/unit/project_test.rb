require 'test_helper'

class ProjectTest < ActiveSupport::TestCase

  context 'Migrations' do
    %w( name institution homepage description contact).each do |column|
      should have_db_column(column).of_type(:string)
    end
  end
    
  context 'Validations' do
    ['http://example.com/', 'https://example.com/', 'file://path/to/file'].each do |val|
      should allow_value(val).for :homepage
    end
  end

  [nil, '', 'fooo'].each do |val|
    should_not allow_value(val).for :homepage
  end
  
end
