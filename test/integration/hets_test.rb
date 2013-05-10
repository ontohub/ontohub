require 'test_helper'

class HetsTest < ActiveSupport::TestCase

  context 'Hets deployment' do
    should 'have an ontology library' do
      assert_nothing_raised do
        Hets.library_path
      end
    end
  end

  context 'Hets ontology library' do
    should 'exist' do
      assert File.exists? Hets.library_path
    end
  end
end
