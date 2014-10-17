require 'spec_helper'

describe LanguageAdjointsController do
  let!(:source) { create(:logic) }
  let!(:target) { create(:logic) }
  let!(:mapping) do
    create(:logic_mapping, source: source, target: target)
  end

  let!(:user) { create :user }
  let!(:target_language) { create :language, user: user }
  let!(:source_language) { create :language, user: user }
  let!(:mapping) do
    create :language_mapping,
      source: source_language, target: target_language, user: user
  end
  let!(:target_language2) { create :language, user: user }
  let!(:source_language2) { create :language, user: user }
  let!(:mapping2) do
    create :language_mapping,
      source: source_language2, target: target_language2, user: user
  end
  let!(:adjoint) do
    create :language_adjoint,
      translation: mapping, projection: mapping2, user: user
  end

  context 'signed in as owner' do
    before { sign_in user }

    context 'on get to show' do
      before { get :show, id: adjoint.id, mapping_id: mapping.id }
      it { should respond_with :success }
      it { should render_template :show }
      it { should_not set_the_flash }
    end

    context 'on get to new' do
      before { get :new, mapping_id: mapping.id }

      it { should respond_with :success }
      it { should render_template :new }
    end

    context 'on POST to CREATE' do
      before do
        post :create, language_mapping_id: mapping.id, language_adjoint: {
          translation_id: mapping.id,
          projection_id: mapping2.id,
          iri: 'http://test.de'
        }
      end

      context 'create the record' do
        let!(:adjoint_from_db) { LanguageAdjoint.find_by_iri('http://test.de') }

        it 'should exist' do
          expect(adjoint_from_db).not_to be_nil
        end

        it 'should have correct translation' do
          expect(adjoint_from_db.translation).to eq(mapping)
        end

        it 'should have correct projection' do
          expect(adjoint_from_db.projection).to eq(mapping2)
        end
      end
    end

    context 'on PUT to Update' do
      before do
        put :update, id: adjoint.id, language_adjoint: {
          translation_id: mapping.id,
          projection_id: mapping2.id,
          iri: 'http://test2.de'
        }
      end

      context 'change the record' do
        let!(:adjoint_from_db) { LanguageAdjoint.find_by_iri('http://test2.de') }

        it 'should exist' do
          expect(adjoint_from_db).not_to be_nil
        end

        it 'should have correct translation' do
          expect(adjoint_from_db.translation).to eq(mapping)
        end

        it 'should have correct projection' do
          expect(adjoint_from_db.projection).to eq(mapping2)
        end
      end
    end

    context 'on POST to DELETE' do
      before { delete :destroy, id: adjoint.id, mapping_id: mapping.id }

      it 'remove the record' do
        expect(LanguageAdjoint.find_by_id(adjoint.id)).to be_nil
      end
    end

    context 'on GET to EDIT' do
      before { get :edit, id: adjoint.id, mapping_id: mapping.id }
      it { should respond_with :success }
      it { should render_template :edit }
      it { should_not set_the_flash }
    end
  end

  context 'signed in as not-owner' do
    let!(:user2) { create :user }
    before { sign_in user2 }

    context 'on get to show' do
      before { get :show, id: adjoint.id, mapping_id: mapping.id }
      it { should respond_with :success }
      it { should render_template :show }
      it { should_not set_the_flash }
    end

    context 'on get to new' do
      before { get :new, mapping_id: mapping.id }

      it { should respond_with :success }
      it { should render_template :new }
    end

    context 'on POST to CREATE' do
      before do
        post :create, language_mapping_id: mapping.id, language_adjoint: {
          translation_id: mapping.id,
          projection_id: mapping2.id,
          iri: 'http://test.de'
        }
      end

      context 'create the record' do
        let!(:adjoint_from_db) { LanguageAdjoint.find_by_iri('http://test.de') }

        it 'should exist' do
          expect(adjoint_from_db).not_to be_nil
        end

        it 'should have correct translation' do
          expect(adjoint_from_db.translation).to eq(mapping)
        end

        it 'should have correct projection' do
          expect(adjoint_from_db.projection).to eq(mapping2)
        end
      end
    end

    context 'on PUT to Update' do
      before do
        put :update, id: adjoint.id, language_adjoint: {
          translation_id: mapping.id,
          projection_id: mapping2.id,
          iri: "http://test2.de"
        }
      end

      it 'not change the record' do
        expect(LanguageAdjoint.find_by_iri('http://test2.de')).to be_nil
      end
    end

    context 'on POST to DELETE' do
      before { delete :destroy, id: adjoint.id, translation_id: mapping.id }

      it 'not remove the record' do
        expect(LanguageAdjoint.find_by_id(adjoint.id)).to eq(adjoint)
      end
    end

    context 'on GET to EDIT' do
      before { get :edit, id: adjoint.id, translation_id: mapping.id }
      it { should respond_with :redirect }
      it { should set_the_flash.to(/not authorized/i) }
    end
  end

  context 'not signed in' do
    context 'on get to show' do
      before { get :show, id: adjoint.id, translation_id: mapping.id }
      it { should respond_with :success }
      it { should render_template :show }
      it { should_not set_the_flash }
    end

    context 'on get to new' do
      before { get :new, translation_id: mapping.id }

      it { should respond_with :redirect }
      it { should set_the_flash }
    end

    context 'on POST to CREATE' do
      before do
        post :create, language_mapping_id: mapping.id, language_adjoint: {
          translation_id: mapping.id,
          projection_id: mapping2.id,
          iri: 'http://test.de'
        }
      end

      it 'not create the record' do
        expect(LanguageAdjoint.find_by_iri("http://test.de")).to be_nil
      end
    end

    context 'on PUT to Update' do
      before do
        put :update, id: adjoint.id, language_adjoint: {
          translation_id: mapping.id,
          projection_id: mapping2.id,
          iri: 'http://test2.de'
        }
      end

      it 'not change the record' do
        expect(LanguageAdjoint.find_by_iri('http://test2.de')).to be_nil
      end
    end

    context 'on POST to DELETE' do
      before { delete :destroy, id: adjoint.id, translation_id: mapping.id }

      it 'not remove the record' do
        expect(LanguageAdjoint.find_by_id(adjoint.id)).to eq(adjoint)
      end
    end
  end
end
