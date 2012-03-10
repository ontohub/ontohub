require 'test_helper'

class PermissionTest < ActiveSupport::TestCase
  context 'Ontology' do
    setup do
      @ontology = Factory :ontology
    end

    context 'admin user' do
      setup do
        @admin = Factory :admin
      end

      should 'have owner and editor permissions' do
        assert @ontology.permission?(:owner,  @admin)
        assert @ontology.permission?(:editor, @admin)
      end
    end

    context 'owner user' do
      setup do
        @permission = Factory :permission, item: @ontology
      end

      should 'have owner and editor permissions' do
        assert @ontology.permission?(:owner,  @permission.subject)
        assert @ontology.permission?(:editor, @permission.subject)
      end
    end

    context 'editor user' do
      setup do
        @permission = Factory :permission, item: @ontology, role: 'editor'
      end

      should 'have editor permission' do
        assert @ontology.permission?(:editor, @permission.subject)
      end
    end

    context 'team user' do
      setup do
        @team_user = Factory :team_user
        @permission = Factory :permission, item: @ontology, subject: @team_user.team
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
        @permission = Factory :permission, item: @ontology, role: 'editor'
      end

      should 'not have owner permission' do
        assert !@ontology.permission?(:owner, @permission.subject)
      end
    end

    context 'user on other team' do
      setup do
        @team_user = Factory :team_user
        @permission = Factory :permission, item: @ontology
      end

      should 'not have owner and editor permissions' do
        assert !@ontology.permission?(:owner,  @team_user.user)
        assert !@ontology.permission?(:editor, @team_user.user)
      end
    end

    context 'some user' do
      setup do
        @user = Factory :user
      end

      should 'not have permissions without ontology having permissions' do
        assert !@ontology.permission?(:owner,  @user)
        assert !@ontology.permission?(:editor, @user)
      end
    end
  end
end
