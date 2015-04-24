require 'spec_helper'

describe LanguagesController do
  let!(:user) { create :user }
  let!(:language) { create :language, user: user }

  context 'on GET to show' do
    context 'not signed in' do
      before { get :show, id: language.to_param }

      it { should respond_with :success }
      it { should render_template :show }

      it 'does not set the flash' do
        expect(flash).to be_empty
      end
    end

    context 'signed in as Language-Owner' do
      before do
        sign_in user
        get :show, id: language.to_param
      end

      it { should respond_with :success }
      it { should render_template :show }

      it 'does not set the flash' do
        expect(flash).to be_empty
      end
    end
  end

  context 'in GET to index' do
    before { get :index }

    it { should respond_with :success }
    it { should render_template :index }

    it 'does not set the flash' do
      expect(flash).to be_empty
    end
  end

  context 'on POST to create' do
    let!(:language2) { build(:language) }
    before do
      sign_in user
      post :create, language: {
        name:  language2.name,
        iri: language2.iri
      }
    end

    it 'create the record' do
      expect(Language.find_by_name(language2.name).name).to eq(language2.name)
    end

    it { should respond_with :redirect }

    it 'sets the flash' do
      expect(flash[:notice]).to match(/created/i)
    end
  end

  context 'on POST to update' do
    let!(:oldname) { language.name }

    context 'signed in' do
      before do
        sign_in user
        post :update, id: language.id, language: {
          name: "test3"
        }
      end

      it 'not leave the record' do
        expect(Language.find_by_name(oldname)).to be_falsy
      end

      it 'change the record' do
        expect(Language.find_by_name("test3")).to be_truthy
      end

      it { should respond_with :redirect }

      it 'sets the flash' do
        expect(flash[:notice]).to match(/successfully updated/i)
      end
    end

    context 'not signed in' do
      before do
        post :update, id: language.id, language: {
          name: "test3"
        }
      end

      it 'leave the record' do
        expect(Language.find_by_name(oldname)).to be_truthy
      end

      it 'not change the record' do
        expect(Language.find_by_name("test3")).to be_falsy
      end

      it { should respond_with :redirect }

      it 'sets the flash' do
        expect(flash[:alert]).not_to match(/successfully updated/i)
      end
    end

    context 'not permitted' do
      let!(:user2) { create :user }
      let!(:oldname) { language.name }
      before do
        sign_in user2
        post :update, id: language.id, language: {
          name: 'test3'
        }
      end

      it 'leave the record' do
        expect(Language.find_by_name(oldname)).to be_truthy
      end

      it 'not change the record' do
        expect(Language.find_by_name('test3')).to be_falsy
      end

      it { should respond_with :redirect }

      it 'sets the flash' do
        expect(flash[:alert]).not_to match(/successfully updated/i)
      end
    end

  end

  context 'on POST to DELETE' do
    context 'signed in' do
      before do
        sign_in user
        delete :destroy, id: language.id
      end

      it 'not leave the record' do
        expect(Language.find_by_name(language.name)).to be_falsy
      end

      it { should respond_with :redirect }

      it 'sets the flash' do
        expect(flash[:notice]).to match(/successfully destroyed/i)
      end
    end

    context 'not signed in' do
      before { delete :destroy, id: language.id }

      it 'leave the record' do
        expect(Language.find_by_name(language.name)).to be_truthy
      end

      it { should respond_with :redirect }

      it 'sets the flash' do
        expect(flash[:alert]).not_to match(/successfully destroyed/i)
      end
    end

    context 'not permitted' do
      let!(:user2) { create :user }
      before do
        sign_in user2
        delete :destroy, id: language.id
      end

      it 'leave the record' do
        expect(Language.find_by_name(language.name)).to be_truthy
      end

      it { should respond_with :redirect }

      it 'sets the flash' do
        expect(flash[:alert]).not_to match(/successfully destroyed/i)
      end
    end

  end
end
