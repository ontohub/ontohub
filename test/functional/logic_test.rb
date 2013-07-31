require 'test_helper'

class LogicTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create :user
  end
  
  context 'saving a transient logic' do
    context 'whose iri has http scheme' do
      logic = FactoryGirl.create :logic, :user => @user
      logic.name = 'FOL'
      logic.iri  = 'http://logic.org/FOL'
      logic.save!
    end

    context 'whose iri has urn scheme' do
      logic = FactoryGirl.create :logic, :user => @user
      logic.name = 'CommonLogic'
      logic.iri  = 'urn:logic:CommonLogic'
      logic.save!
    end

    context 'whose iri has ftp scheme' do
      logic = FactoryGirl.create :logic, :user => @user
      logic.name = 'DescriptiveLogic'
      logic.iri  = 'ftp://logic.org/DL'
      logic.save!
    end
  end
end
