require 'spec_helper'

describe SerializationsController do
  let!(:user) { FactoryGirl.create :user }
  let!(:language) { FactoryGirl.create :language, user: user }
  let!(:serial) { FactoryGirl.create :serialization, language: language }

  context 'signed in as owner' do
    before do
      sign_in user
    end

    context 'on get to show' do
      before do
        get :show, id: serial.id
      end

      it { should respond_with :success }
      it { should render_template :show }
      it { should_not set_the_flash }
    end

    context 'on get to new' do
      before do
        get :new
      end

      it { should respond_with :success }
      it { should render_template :new }
    end

    context 'on POST to CREATE' do
      before do
        post :create, serialization: {
          name: 'test132',
          mimetype: 'text',
          language_id: language.id
        }
      end

      context 'create the record' do
        let!(:serial_from_db) { Serialization.find_by_name('test132') }
        it 'should exist' do
          expect(serial_from_db).not_to be_nil
        end

        it 'should have correct mime type' do
          expect(serial_from_db.mimetype).to eq('text')
        end

        it 'should have correct name' do
          expect(serial_from_db.name).to eq('test132')
        end
      end
    end

    context 'on PUT to Update' do
      before do
        put :update, id: serial.id, serialization: {
          name: 'test4325',
          mimetype: 'texttext' }
      end

      context 'change the record' do
        let!(:serial_from_db) { Serialization.find_by_name('test4325') }
        it 'should exist' do
          expect(serial_from_db).not_to be_nil
        end

        it 'should have correct mime type' do
          expect(serial_from_db.mimetype).to eq('texttext')
        end

        it 'should have correct name' do
          expect(serial_from_db.name).to eq('test4325')
        end
      end
    end

    context 'on POST to DELETE' do
      before do
        delete :destroy, id: serial.id
      end

      it 'remove the record' do
        expect(Serialization.find_by_id(serial.id)).to be_nil
      end
    end

    context 'on GET to EDIT' do
      before do
        get :edit, id: serial.id
      end
      it { should respond_with :success }
      it { should render_template :edit }
      it { should_not set_the_flash }
    end
  end

  context 'signed in as not-owner' do
    let(:user2) { FactoryGirl.create :user }
    before { sign_in user2 }

    context 'on get to show' do
      before do
        get :show, id: serial.id
      end
      it { should respond_with :success }
      it { should render_template :show }
      it { should_not set_the_flash }
    end

    context 'on get to new' do
      before do
        get :new
      end

      it { should respond_with :success }
      it { should render_template :new }
    end

    context 'on POST to CREATE' do
      before do
        post :create, serialization: {
          name: 'test132',
          mimetype: 'text',
          language_id: language.id }
      end

      context 'create the record' do
        let!(:serial_from_db) { Serialization.find_by_name('test132') }
        it 'should exist' do
          expect(serial_from_db).not_to be_nil
        end

        it 'should have correct mime type' do
          expect(serial_from_db.mimetype).to eq('text')
        end

        it 'should have correct name' do
          expect(serial_from_db.name).to eq('test132')
        end
      end
    end

    context 'on PUT to Update' do
      before do
        put :update, id: serial.id, serialization: {
          name: 'test4325',
          mimetype: 'texttext'
        }
      end

      context 'change the record' do
        let!(:serial_from_db) { Serialization.find_by_name('test4325') }
        it 'should exist' do
          expect(serial_from_db).not_to be_nil
        end

        it 'should have correct mime type' do
          expect(serial_from_db.mimetype).to eq('texttext')
        end

        it 'should have correct name' do
          expect(serial_from_db.name).to eq('test4325')
        end
      end
    end

    context 'on POST to DELETE' do
      before do
        delete :destroy, id: serial.id
      end

      it 'remove the record' do
        expect(Serialization.find_by_id(serial.id)).to be_nil
      end
    end

    context 'on GET to EDIT' do
      before do
        get :edit, id: serial.id
      end
      it { should respond_with :success }
      it { should render_template :edit }
      it { should_not set_the_flash }
    end
  end

  context 'not signed in' do
    context 'on get to show' do
      before do
        get :show, id: serial.id, language_id: language.id
      end
      it { should respond_with :success }
      it { should render_template :show }
      it { should_not set_the_flash }
    end

    context 'on get to new' do
      before do
        get :new, language_id: language.id
      end

      it { should respond_with :redirect }
      it { should set_the_flash }
    end

    context 'on POST to CREATE' do
      before do
        put :update, id: serial.id, serialization: {
          name: 'test2',
          mimetype: 'text',
          language_id: language.id
        }
      end

      it 'not create the record' do
        expect(Serialization.find_by_name('test2')).to be_nil
      end
    end
    context 'on PUT to Update' do
      before do
        put :update, id: serial.id, serialization: {
          name: 'test2',
          mimetype: 'text',
          language_id: language.id
        }
      end

      it 'not change the record' do
        expect(Serialization.find_by_name('test2')).to be_nil
      end
    end

    context 'on POST to DELETE' do
      before do
        delete :destroy, id: serial.id
      end

      it 'not remove the record' do
        expect(Serialization.find_by_id(serial.id)).to eq(serial)
      end
    end
  end
end
