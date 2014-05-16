require 'integration_test_helper'

class PermissionsTest < ActionController::IntegrationTest

  setup do
    @repository = FactoryGirl.create(:repository)
    @user       = FactoryGirl.create :user
    @team       = FactoryGirl.create :team

    # Add user as owner to the repository
    FactoryGirl.create :permission, subject: @user, item: @repository
  end

  test 'login' do
    login_as @user, :scope => :user

    visit repository_permissions_path(@repository)

    within '.relationList' do
      # does only one permission exist?
      assert_equal 1, all('ul li[data-id]').count

      # fill in the autocomplete input
      fill_in 'name', with: @team.name
    end

    # trigger the autocomplete input
    page.execute_script %Q{ $('#name').trigger("mouseenter").trigger("click"); }

    # check for autocomplete suggestions
    assert find("li.ui-menu-item a")

    # select the first suggestion
    page.execute_script %Q{ $('li.ui-menu-item a').trigger('mouseenter').click(); }

    # has the permission been added to the list?
    within '.relationList ul' do
      assert find_link @team.name
      assert_equal 2, all('li[data-id]').count
    end

  end

end
