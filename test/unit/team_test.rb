require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  
  context 'Associations' do
    should have_many :team_users
    should have_many(:users).through(:team_users)
  end
  
  context 'team instance' do
    setup do
      @team = Factory :team
    end
    
    should 'have to_s' do
      assert_equal @team.name, @team.to_s
    end
  end
  
end
