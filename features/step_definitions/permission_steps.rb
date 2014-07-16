Given(/^there exists a repository$/) do
  @repository = FactoryGirl.create :repository
end

Given(/^a User with a permission$/) do
  @user = FactoryGirl.create :user
  FactoryGirl.create :permission, subject: @user, item: @repository
end

Given(/^a team$/) do
  @team = FactoryGirl.create :team
end

Given(/^I am logged in$/) do
  visit root_path
  login_as @user, :scope => :user
end

When(/^I visit the permissions page of my repository$/) do
  visit repository_permissions_path(@repository)
end

When(/^I fill in the name of an team$/) do
  within '.relationList' do
    # does only one permission exist?
     expect(all('ul li[data-id]').size).to eq(1)
    # fill in the autocomplete input
    fill_in 'name', with: @team.name
  end
end

When(/^click on the suggested team$/) do
  pending #should work but it doesent
  # trigger the autocomplete input
  page.execute_script %Q{ $('#name').trigger("mouseenter").trigger("click"); }
  # select the first suggestion
  page.execute_script %Q{ $('li.ui-menu-item a').trigger('mouseenter').click(); }
end

Then(/^the permission for the team should be added$/) do
  # has the permission been added to the list?
  page.should have_link @team.name
    within '.relationList ul' do
    expect(all('ul li[data-id]').size).to eq(2)
  end
end
