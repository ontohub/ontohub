require 'spec_helper'

describe LanguageMappingsController do
  let!(:user) { FactoryGirl.create :user }
  let!(:target_language) { FactoryGirl.create :language, user: user }
  let!(:source_language) { FactoryGirl.create :language, user: user }
  let!(:mapping) do
    FactoryGirl.create :language_mapping,
    source: source_language, target: target_language, user: user
  end

  context 'signed in as owner' do
    before do
      sign_in user
    end

    context 'on get to show' do
      before do
        get :show, id: mapping.id, language_id: source_language.id
      end
      it { should respond_with :success }
      it { should render_template :show }
      it { should_not set_the_flash }
    end

    context 'on get to new' do
      before do
        get :new, language_id: source_language.id
      end

      it { should respond_with :success }
      it { should render_template :new }
    end

    context 'on POST to CREATE' do
      before do
        post :create, language_id: source_language.id,
          language_mapping: {source_id: source_language.id,
            target_id: target_language.id,
            iri: 'http://test.de'
          }
      end

      context 'create the record' do
        let!(:mapping_from_db) { LanguageMapping.find_by_iri('http://test.de') }

        it 'should exist' do
          expect(mapping_from_db).not_to be_nil
        end

        it 'should have correct source' do
          expect(mapping_from_db.source).to eq(source_language)
        end

        it 'should have correct target' do
          expect(mapping_from_db.target).to eq(target_language)
        end
      end
    end

    context 'on PUT to Update' do
      before do
        put :update, language_id: source_language.id, id: mapping.id,
          language_mapping: {
            source_id: source_language.id,
            target_id: target_language.id,
            iri: 'http://test2.de'
          }
      end

      context 'change the record' do
        let!(:mapping_from_db) { LanguageMapping.find_by_iri('http://test2.de') }

        it 'should exist' do
          expect(mapping_from_db).not_to be_nil
        end

        it 'should have correct source' do
          expect(mapping_from_db.source).to eq(source_language)
        end

        it 'should have correct target' do
          expect(mapping_from_db.target).to eq(target_language)
        end
      end
    end

    context 'on POST to DELETE' do
      before do
        delete :destroy, id: mapping.id, language_id: source_language.id
      end

      it 'remove the record' do
        expect(LanguageMapping.find_by_id(mapping.id)).to be_nil
      end
    end

    context 'on GET to EDIT' do
      before do
        get :edit, id: mapping.id, language_id: source_language.id
      end
      it { should respond_with :success }
      it { should render_template :edit }
      it { should_not set_the_flash }
    end
  end



  context 'signed in as not-owner' do
    let!(:user2) { FactoryGirl.create :user }
    before { sign_in user2 }

    context 'on get to show' do
      before do
        get :show, id: mapping.id, language_id: source_language.id
      end
      it { should respond_with :success }
      it { should render_template :show }
      it { should_not set_the_flash }
    end

    context 'on get to new' do
      before do
        get :new, language_id: source_language.id
      end

      it { should respond_with :success }
      it { should render_template :new }
    end

    context 'on POST to CREATE' do
      before do
        post :create, language_id: source_language.id,
          language_mapping: {
            source_id: source_language.id,
            target_id: target_language.id,
            iri: 'http://test.de'
          }
      end

      context 'create the record' do
        let!(:mapping_from_db) { LanguageMapping.find_by_iri('http://test.de') }

        it 'should exist' do
          expect(mapping_from_db).not_to be_nil
        end

        it 'should have correct source' do
          expect(mapping_from_db.source).to eq(source_language)
        end

        it 'should have correct target' do
          expect(mapping_from_db.target).to eq(target_language)
        end
      end
    end

    context 'on PUT to Update' do
      before do
        put :update, language_id: source_language.id, id: mapping.id,
          language_mapping: {
            source_id: source_language.id,
            target_id: target_language.id,
            iri: 'http://test2.de'
          }
      end

      it 'not change the record' do
        expect(LanguageMapping.find_by_iri('http://test2.de')).to be_nil
      end
    end

    context 'on POST to DELETE' do
      before do
        delete :destroy, id: mapping.id, language_id: source_language.id
      end

      it 'not remove the record' do
        expect(LanguageMapping.find_by_id(mapping.id)).to eq(mapping)
      end
    end

    context 'on GET to EDIT' do
      before do
        get :edit, id: mapping.id, language_id: source_language.id
      end
      it { should respond_with :redirect }
      it { should set_the_flash.to(/not authorized/i) }
    end
  end

  context 'not signed in' do
    context 'on get to show' do
      before do
        get :show, id: mapping.id, language_id: source_language.id
      end
      it { should respond_with :success }
      it { should render_template :show }
      it { should_not set_the_flash }
    end

    context 'on get to new' do
      before do
        get :new, language_id: source_language.id
      end

      it { should respond_with :redirect }
      it { should set_the_flash }
    end
  end

  context 'on POST to CREATE' do
    before do
      post :create, language_id: source_language.id,
        language_mapping: {
          source_id: source_language.id,
          target_id: target_language.id,
          iri: 'http://test.de'
        }
    end

    it 'not create the record' do
      expect(LanguageMapping.find_by_iri('http://test.de')).to be_nil
    end
  end

  context 'on PUT to Update' do
    before do
      put :update, language_id: source_language.id, id: mapping.id,
        language_mapping: {
          source_id: source_language.id,
          target_id: target_language.id,
          iri: 'http://test2.de'
        }
    end

    it 'not change the record' do
      expect(LanguageMapping.find_by_iri('http://test2.de')).to be_nil
    end
  end

  context 'on POST to DELETE' do
    before do
      delete :destroy, id: mapping.id, language_id: source_language.id
    end

    it 'not remove the record' do
      expect(LanguageMapping.find_by_id(mapping.id)).to eq(mapping)
    end
  end
end
