require 'integration_test_helper'

class CommentsTest < ActionController::IntegrationTest

  setup do
    @ontology = FactoryGirl.create(:ontology_version).ontology
    @ontology.state = 'done'
    @ontology.save
    @user     = FactoryGirl.create :user
    @repository = @ontology.repository

    # Add user as owner to the ontology
    FactoryGirl.create :permission, subject: @user, item: @ontology.repository
    login_as @user, :scope => :user
  end

  test 'create a comment' do
    comment_text = 'very loooooooong comment'

    visit repository_ontology_comments_path(@repository, @ontology)

    # zero comments at the beginning
    assert_equal 0, all('.comments > ol > li').count

    within '#new_comment' do
      # fill in the autocomplete input
      fill_in 'Text', with: 'Lorem'
      click_button 'Create Comment'
    end

    # is the text too short?
    assert_equal "is too short (minimum is 10 characters)", find(".help-inline").text

    within '#new_comment' do
      # fill in the autocomplete input
      fill_in 'Text', with: comment_text
      click_button 'Create Comment'
    end

    # wait for the comment to be inserted
    comment_li = find '.comments > ol > li'

    # success message
    assert_equal "Thanks for your comment.", find("#new_comment").text

    # author and timestamp
    assert_match /#{@user.to_s} wrote a few seconds ago/, comment_li.text

    # comment text
    assert comment_li.text.include?(comment_text)
  end

  test 'delete a comment' do
    comment = FactoryGirl.create :comment, commentable: @ontology

    visit repository_ontology_comments_path(@repository, @ontology)

    # does one comment exist?
    assert_equal 1, all('.comments > ol > li').count

    within '.comments' do
      # delete the comment
      click_link 'delete'
    end

    # is the comment deleted?
    assert page.has_no_css?('.comments > ol > li')
  end

end
