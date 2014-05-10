require 'spec_helper'

describe CommentsController do

  let(:ontology){   create :ontology }
  let(:repository){ ontology.repository }
  let(:user){       create :user }

  context 'not signed in' do

    context 'on GET to index' do
      context 'without comment' do
        before do
          get :index, :ontology_id => ontology.to_param, :repository_id => repository.to_param
        end

        it{ should respond_with :success }
        it{ should render_template 'comments/index' }
      end

      context 'with comment' do
        before do
          comment = create :comment, :commentable => ontology
          get :index, :ontology_id => ontology.to_param, :repository_id => repository.to_param
        end

        it{ should respond_with :success }
        it{ should render_template 'comments/index' }
      end
    end
  end

  context 'signed in' do

    before do
      sign_in user
    end

    context 'on GET to index' do
      context 'without comment' do
        before do
          get :index, :ontology_id => ontology.to_param, :repository_id => repository.to_param
        end

        it{ should respond_with :success }
        it{ should render_template 'comments/index' }
      end

      context 'with comment' do
        before do
          comment = create :comment, :commentable => ontology
          get :index, :ontology_id => ontology.to_param, :repository_id => repository.to_param
        end

        it{ should respond_with :success }
        it{ should render_template 'comments/index' }
      end

      context 'on POST to delete' do
        before do
          comment = create :comment, :commentable => ontology, :user => user
          xhr :delete, :destroy, :ontology_id => ontology.to_param, :repository_id => repository.to_param, :id => comment.id
        end

        it{ should respond_with :success }
      end
    end

    context 'on POST to create' do
      context 'with too short text' do
        before do
          xhr :post, :create,
            ontology_id: ontology.to_param,
            repository_id: repository.to_param,
            comment:     {text: 'foo'}
        end
        it{ should respond_with :unprocessable_entity }
      end

      context 'with too enough text' do
        before do
          xhr :post, :create,
            ontology_id: ontology.to_param,
            repository_id: repository.to_param,
            comment:     {text: 'fooo baaaaaaaaaaaaaaar'}
        end

        it{ should respond_with :success }
      end
    end
  end

end
