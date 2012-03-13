require 'test_helper'

class AbilityTest < ActiveSupport::TestCase
  
  context 'Ontology' do
    setup do
      @owner  = Factory :user # owner
      @editor = Factory :user # editor
      @user   = Factory :user # regular user
      
      @item = Factory(:permission, subject: @owner, role: 'owner').item
      Factory(:permission, subject: @editor, role: 'editor', item: @item)
    end

    context 'owner' do
      setup do
        @ability = Ability.new(@owner)
      end
      
      should 'be allowed: new, create' do
        [:new, :create].each do |perm|
          assert @ability.can?(perm, Ontology.new)
        end
      end

      should 'be allowed: edit, update, destroy, permissions' do
        [:edit, :update, :destroy, :permissions].each do |perm|
          assert @ability.can?(perm, @item)
        end
      end

      should 'not be allowed on other: edit, update, destroy, permissions' do
        [:edit, :update, :destroy, :permissions].each do |perm|
          assert @ability.cannot?(perm, Factory(:ontology))
        end
      end
    end

    context 'editor' do
      setup do
        @ability = Ability.new(@editor)
      end
      
      should 'be allowed: edit, update' do
        [:edit, :update].each do |perm|
          assert @ability.can?(perm, @item)
        end
      end

      should 'not be allowed: destroy, permissions' do
        [:destroy, :permissions].each do |perm|
          assert @ability.cannot?(perm, @item)
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
  
  context 'Comment' do
    setup do
      @comment = Factory :comment
    end
    
    context 'author' do
      setup do
        @ability = Ability.new(@comment.user)
      end
      
      should 'destroy his own comment' do
        assert @ability.can?(:destroy, @comment)
      end
      
      should 'not be allowed to destroy others comment' do
        assert @ability.cannot?(:destroy, Factory(:comment))
      end
    end
    
    context 'admin' do
      setup do
        @ability = Ability.new(Factory :admin)
      end
      should 'destroy others comment' do
        assert @ability.can?(:destroy, @comment)
      end
    end
    
    context 'comments ontology owner' do
      setup do
        @owner = Factory :user
        Factory(:permission, subject: @owner, role: 'owner', item: @comment.commentable)
        
        @ability = Ability.new(@owner)
      end
      
      should 'destroy others comments for his ontology' do
        assert @ability.can?(:destroy, @comment)
      end
    end
    
    context 'comments ontology editor' do
      setup do
        @owner = Factory :user
        Factory(:permission, subject: @owner, role: 'editor', item: @comment.commentable)
        
        @ability = Ability.new(@owner)
      end
      
      should 'not destroy others comments for his ontology' do
        assert @ability.cannot?(:destroy, @comment)
      end
    end
  end
end
