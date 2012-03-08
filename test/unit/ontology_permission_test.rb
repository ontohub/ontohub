require 'test_helper'

class OntologyPermissionTest < ActiveSupport::TestCase
  context 'Ontology permission' do
    setup do
      @ontology = Factory :ontology
      @ontology.owner = Factory :user
    end

    context 'for admin' do
      setup do
        @admin = Factory :admin
      end

      should 'be granted' do
        assert @ontology.permission?(@admin)
      end
    end

    context 'for owner' do
      setup do
        @owner = @ontology.owner
      end

      should 'be granted' do
        assert @ontology.permission?(@owner)
      end
    end

    context 'for team' do
      setup do
        @team = Factory :team
        @ontology.owner = @team
      end

      should 'be granted' do
        assert @ontology.permission?(@team)
      end
    end

    context 'for team user' do
      setup do
        @team_user = Factory :team_user
        @ontology.owner = @team_user.team
      end

      should 'be granted' do
        assert @ontology.permission?(@team_user.user)
      end
    end

    context 'for bernd' do
      should 'be granted' do
        assert !@ontology.permission?(nil)
      end
    end
  end
end
