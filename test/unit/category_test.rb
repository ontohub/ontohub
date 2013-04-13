require 'test_helper'

class CategoryTest < ActiveSupport::TestCase

context 'Migrations' do
    %w( ontology_id ).each do |column|
      should have_db_column(column).of_type(:integer)
    end
  end
end
