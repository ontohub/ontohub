require 'test_helper'

class LogicTest < ActiveSupport::TestCase

  context 'Logic instance' do
    setup do
      @user = FactoryGirl.create :user
      @logic = FactoryGirl.create :logic, user: @user
    end

    should 'have to_s' do
      assert_equal @logic.name, @logic.to_s
    end

    should 'allow http scheme for IRI' do
      assert_nothing_raised do
        @logic.iri = 'http://example.com/logic'
        @logic.save!
      end
    end

    should 'allow URN scheme for IRI' do
      assert_nothing_raised do
        @logic.iri = 'urn:logic:CommonLogic'
        @logic.save!
      end
    end

    should 'not allow ftp scheme for IRI' do
      assert_raise ActiveRecord::RecordInvalid do
        @logic.iri = 'ftp://example.com/logic'
        @logic.save!
      end
    end

  end

end
