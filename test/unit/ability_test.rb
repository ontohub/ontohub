require 'test_helper'

class AbilityTest < ActiveSupport::TestCase
  context 'Ontology' do
    setup do
      @user = Factory :user
      @other = Factory :user
      @ability = Ability.new(@user)
    end

    context 'owner' do
      should 'be allowed: new, create' do
        [:new, :create].each do |perm|
          assert @ability.can?(perm, Ontology.new)
        end
      end

      should 'be allowed: edit, update, destroy, permissions' do
        [:edit, :update, :destroy, :permissions].each do |perm|
          assert @ability.can?(perm, Factory(:permission, subject: @user).item)
        end
      end

      should 'not be allowed on other: edit, update, destroy, permissions' do
        [:edit, :update, :destroy, :permissions].each do |perm|
          assert @ability.cannot?(perm, Factory(:permission, subject: @other).item)
        end
      end
    end

    context 'editor' do
      should 'be allowed: edit, update' do
        [:edit, :update].each do |perm|
          assert @ability.can?(perm, Factory(:permission, subject: @user, role: 'editor').item)
        end
      end

      should 'not be allowed: destroy, permissions' do
        [:destroy, :permissions].each do |perm|
          assert @ability.cannot?(perm, Factory(:permission, subject: @user, role: 'editor').item)
        end
      end
    end
  end

  context 'Team' do
    setup do
      @user = Factory :user
      @other = Factory :user
      @ability = Ability.new(@user)

      @memberteam = Factory(:team_user, user: @other).team
      @memberteam.users << @user

      @otherteam = Factory(:team_user, user: @other).team
    end

    context 'admin' do
      should 'be allowed: edit, update, destroy' do
        [:edit, :update, :destroy].each do |perm|
          assert @ability.can?(perm, Factory(:team_user, user: @user).team)
        end
      end
    end

    context 'member' do
      should 'be allowed: create, show, index' do
        [:create, :show, :index].each do |perm|
          assert @ability.can?(perm, Team.new)
        end
      end

      should 'not be allowed: edit, update, destroy (without admin on team)' do
        [:edit, :update, :destroy].each do |perm|
          assert @ability.cannot?(perm, @memberteam)
        end
      end

      should 'not be allowed: edit, update, destroy (without being on team)' do
        [:edit, :update, :destroy].each do |perm|
          assert @ability.cannot?(perm, @otherteam)
        end
      end
    end
  end
end
