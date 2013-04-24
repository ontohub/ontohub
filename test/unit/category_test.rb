require 'test_helper'

class CategoryTest < ActiveSupport::TestCase

  context 'Migrations' do
    should have_db_column('name').of_type(:string)
  end

end
