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
  
  context 'Ontology' do
    setup do
      @ontology = FactoryGirl.create :ontology
    end

    context 'admin user' do
      setup do
        @admin = FactoryGirl.create :admin
      end

      should 'have owner and editor permissions' do
        assert @ontology.permission?(:owner,  @admin)
        assert @ontology.permission?(:editor, @admin)
      end
    end

    context 'owner user' do
      setup do
        @permission = FactoryGirl.create :permission, item: @ontology
      end

      should 'have owner and editor permissions' do
        assert @ontology.permission?(:owner,  @permission.subject)
        assert @ontology.permission?(:editor, @permission.subject)
      end
    end

    context 'editor user' do
      setup do
        @permission = FactoryGirl.create :permission, item: @ontology, role: 'editor'
      end

      should 'have editor permission' do
        assert @ontology.permission?(:editor, @permission.subject)
      end
    end

    context 'team user' do
      setup do
        @team_user = FactoryGirl.create :team_user
        @permission = FactoryGirl.create :permission, item: @ontology, subject: @team_user.team
      end

      should 'have owner and editor permissions' do
        assert @ontology.permission?(:owner,  @team_user.user)
        assert @ontology.permission?(:editor, @team_user.user)
      end
    end

    context 'bernd' do
      should 'not have any permissions' do
        assert !@ontology.permission?(:owner,  nil)
        assert !@ontology.permission?(:editor, nil)
      end
    end

    context 'editor' do
      setup do
        @permission = FactoryGirl.create :permission, item: @ontology, role: 'editor'
      end

      should 'not have owner permission' do
        assert !@ontology.permission?(:owner, @permission.subject)
      end
    end

    context 'user on other team' do
      setup do
        @team_user = FactoryGirl.create :team_user
        @permission = FactoryGirl.create :permission, item: @ontology
      end

      should 'not have owner and editor permissions' do
        assert !@ontology.permission?(:owner,  @team_user.user)
        assert !@ontology.permission?(:editor, @team_user.user)
      end
    end

    context 'some user' do
      setup do
        @user = FactoryGirl.create :user
      end

      should 'not have permissions without ontology having permissions' do
        assert !@ontology.permission?(:owner,  @user)
        assert !@ontology.permission?(:editor, @user)
      end
    end
  end
end
