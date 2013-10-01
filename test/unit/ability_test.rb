require 'test_helper'

class AbilityTest < ActiveSupport::TestCase
  
  context 'Repository' do
    setup do
      @owner  = FactoryGirl.create :user # owner
      @editor = FactoryGirl.create :user # editor
      @user   = FactoryGirl.create :user # regular user
      
      @item = FactoryGirl.create(:permission, subject: @owner, role: 'owner').item
      FactoryGirl.create(:permission, subject: @editor, role: 'editor', item: @item)
    end

    context 'guest' do
      setup do
        @ability = Ability.new(User.new)
      end
      
      should 'not be allowed: new, create' do
        [:new, :create].each do |perm|
          assert @ability.cannot?(perm, Repository.new)
        end
      end

      should 'not be allowed some actions' do
        [:edit, :update, :destroy, :write].each do |perm|
          assert @ability.cannot?(perm, @item)
        end
      end
    end

    context 'owner' do
      setup do
        @ability = Ability.new(@owner)
      end
      
      should 'be allowed: new, create' do
        [:new, :create].each do |perm|
          assert @ability.can?(perm, Repository.new)
        end
      end

      should 'be allowed: edit, update, destroy, permissions, write' do
        [:edit, :update, :destroy, :permissions].each do |perm|
          assert @ability.can?(perm, @item)
        end
      end

      should 'not be allowed on other: edit, update, destroy, permissions' do
        [:edit, :update, :destroy, :permissions].each do |perm|
          assert @ability.cannot?(perm, FactoryGirl.create(:repository))
        end
      end
    end

    context 'editor' do
      setup do
        @ability = Ability.new(@editor)
      end
      
      should 'be allowed: write' do
        [:write].each do |perm|
          assert @ability.can?(perm, @item)
        end
      end

      should 'not be allowed: edit, update, destroy, permissions' do
        [:edit, :update, :destroy, :permissions].each do |perm|
          assert @ability.cannot?(perm, @item)
        end
      end
    end
  end

  context 'Team' do
    setup do
      @user = FactoryGirl.create :user
      @other = FactoryGirl.create :user
      @ability = Ability.new(@user)

      @memberteam = FactoryGirl.create(:team_user, user: @other).team
      @memberteam.users << @user

      @otherteam = FactoryGirl.create(:team_user, user: @other).team
    end

    context 'admin' do
      should 'be allowed: edit, update, destroy' do
        [:edit, :update, :destroy].each do |perm|
          assert @ability.can?(perm, FactoryGirl.create(:team_user, user: @user).team)
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
  
  context 'Comment' do
    setup do
      @comment = FactoryGirl.create :comment
    end
    
    context 'author' do
      setup do
        @ability = Ability.new(@comment.user)
      end
      
      should 'destroy his own comment' do
        assert @ability.can?(:destroy, @comment)
      end
      
      should 'not be allowed to destroy others comment' do
        assert @ability.cannot?(:destroy, FactoryGirl.create(:comment))
      end
    end
    
    context 'admin' do
      setup do
        @ability = Ability.new(FactoryGirl.create :admin)
      end
      should 'destroy others comment' do
        assert @ability.can?(:destroy, @comment)
      end
    end
    
    context 'comments repository owner' do
      setup do
        @owner = FactoryGirl.create :user
        FactoryGirl.create(:permission, subject: @owner, role: 'owner', item: @comment.commentable.repository)
        
        @ability = Ability.new(@owner)
      end
      
      should 'destroy others comments for his repository' do
        assert @ability.can?(:destroy, @comment)
      end
    end
    
    context 'comments repository editor' do
      setup do
        @owner = FactoryGirl.create :user
        FactoryGirl.create(:permission, subject: @owner, role: 'editor', item: @comment.commentable.repository)
        
        @ability = Ability.new(@owner)
      end
      
      should 'not destroy others comments for his repository' do
        assert @ability.cannot?(:destroy, @comment)
      end
    end
  end
end
