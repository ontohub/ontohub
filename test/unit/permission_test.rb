require 'test_helper'

class PermissionTest < ActiveSupport::TestCase

  should belong_to :creator
  should belong_to :item
  should belong_to :subject

  [ 'owner', 'editor' ].each do |val|
    should allow_value(val).for :role
  end

  [ nil, '','foo' ].each do |val|
    should_not allow_value(val).for :role
  end

  context 'repository' do
    setup do
      @repository = FactoryGirl.create :repository
    end

    context 'admin user' do
      setup do
        @admin = FactoryGirl.create :admin
      end

      should 'have owner and editor permissions' do
        assert @repository.permission?(:owner,  @admin)
        assert @repository.permission?(:editor, @admin)
      end
    end

    context 'owner user' do
      setup do
        @permission = FactoryGirl.create :permission, item: @repository
      end

      should 'have owner and editor permissions' do
        assert @repository.permission?(:owner,  @permission.subject)
        assert @repository.permission?(:editor, @permission.subject)
      end
    end

    context 'editor user' do
      setup do
        @permission = FactoryGirl.create :permission, item: @repository, role: 'editor'
      end

      should 'have editor permission' do
        assert @repository.permission?(:editor, @permission.subject)
      end
    end

    context 'team user' do
      setup do
        @team_user = FactoryGirl.create :team_user
        @permission = FactoryGirl.create :permission, item: @repository, subject: @team_user.team
      end

      should 'have owner and editor permissions' do
        assert @repository.permission?(:owner,  @team_user.user)
        assert @repository.permission?(:editor, @team_user.user)
      end
    end

    context 'bernd' do
      should 'not have any permissions' do
        assert !@repository.permission?(:owner,  nil)
        assert !@repository.permission?(:editor, nil)
      end
    end

    context 'editor' do
      setup do
        @permission = FactoryGirl.create :permission, item: @repository, role: 'editor'
      end

      should 'not have owner permission' do
        assert !@repository.permission?(:owner, @permission.subject)
      end
    end

    context 'user on other team' do
      setup do
        @team_user = FactoryGirl.create :team_user
        @permission = FactoryGirl.create :permission, item: @repository
      end

      should 'not have owner and editor permissions' do
        assert !@repository.permission?(:owner,  @team_user.user)
        assert !@repository.permission?(:editor, @team_user.user)
      end
    end

    context 'some user' do
      setup do
        @user = FactoryGirl.create :user
      end

      should 'not have permissions without repository having permissions' do
        assert !@repository.permission?(:owner,  @user)
        assert !@repository.permission?(:editor, @user)
      end
    end
  end
end
