require 'test_helper'

class TeamTest < ActiveSupport::TestCase

  should strip_attribute :name
  should have_many :permissions

  context 'Associations' do
    should have_many :team_users
    should have_many(:users).through(:team_users)
  end

  [ 'foo', '123 4', 'A multiword name' ].each do |val|
    should allow_value(val).for :name
  end

  [ nil, '','   A   ', 'fo','a very tooooooooooooooooooooooooooooooooooooooooooooooo long name' ].each do |val|
    should_not allow_value(val).for :name
  end

  context 'team instance' do
    setup do
      @team = FactoryGirl.create :team
    end

    should 'have to_s' do
      assert_equal @team.name, @team.to_s
    end

  end

end
