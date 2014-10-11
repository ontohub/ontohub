require 'spec_helper'

describe AutocompleteController do
  context 'users and teams' do
    let!(:term) { 'foo' }
    let!(:user) { FactoryGirl.create :user, name: "#{term}user" }
    let!(:team) { FactoryGirl.create :team, name: "#{term}team" }

    context 'on GET to index' do
      context 'with results' do
        before do
          get :index,
            scope: 'User,Team',
            term:  term
        end

        it 'return two entries' do
          expect(JSON.parse(response.body).size).to eq(2)
        end

        it 'respond with json content type' do
          expect(response.content_type.to_s).to eq('application/json')
        end

        it { should respond_with :success }
      end

      context 'with results, one excluded' do
        before do
          get :index,
            scope: 'User,Team',
            term:  term,
            exclude: { User: user.id }
        end

        it 'return one entry' do
          expect(JSON.parse(response.body).size).to eq(1)
        end

        it 'respond with json content type' do
          expect(response.content_type.to_s).to eq('application/json')
        end

        it { should respond_with :success }
      end

      context 'without results' do
        before do
          get :index,
            scope: 'User,Team',
            term:  'xxxyyyzzz'
        end

        it { should respond_with :success }
      end
    end

  end

  context 'on GET to index' do
    context 'with invalid scope' do
      before do
        get :index,
          scope: 'foo',
          term:  'bar'
      end

      it { should respond_with :unprocessable_entity }
    end

    context 'without scope' do
      it 'throw RuntimeError' do
        expect do
          get :index,
            term:  'foo'
        end.to raise_error(RuntimeError)
      end
    end

    context 'on GET to index with empty term' do
      before do
        get :index,
          scope: 'foo',
          term:  ''
      end

      it { should respond_with :success }
    end

    context 'on GET to index without term' do
      before do
        get :index,
          scope: 'foo'
      end

      it { should respond_with :success }
    end
  end
end
