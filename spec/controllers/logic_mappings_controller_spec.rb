require 'spec_helper'

describe LogicMappingsController do
  let!(:user) { create :user }
  let!(:target_logic) { create :logic, user: user }
  let!(:source_logic) { create :logic, user: user }
  let!(:mapping) do
    create :logic_mapping,
      source: source_logic, target: target_logic, user: user
  end

  context 'signed in as owner' do
    before { sign_in user }

    context 'on get to show' do
      before { get :show, id: mapping.to_param, logic_id: source_logic.id }
      it { should respond_with :success }
      it { should render_template :show }

      it 'does not set the flash' do
        expect(flash).to be_empty
      end
    end

    context 'on get to new' do
      before { get :new, logic_id: source_logic.id }

      it { should respond_with :success }
      it { should render_template :new }
    end

    context 'on POST to CREATE' do
      before do
        post :create, logic_id: source_logic.id,
          logic_mapping: {
            source_id: source_logic.id,
            target_id: target_logic.id,
            iri: 'http://test.de'
          }
      end

      context 'create the record' do
        let!(:mapping_from_db) { LogicMapping.find_by_iri('http://test.de') }

        it 'should exist' do
          expect(mapping_from_db).not_to be(nil)
        end

        it 'should have correct source' do
          expect(mapping_from_db.source).to eq(source_logic)
        end

        it 'should have correct target' do
          expect(mapping_from_db.target).to eq(target_logic)
        end
      end
    end

    context 'on PUT to Update' do
      before do
        put :update, logic_id: source_logic.id, id: mapping.to_param,
          logic_mapping: {
            source_id: source_logic.id,
            target_id: target_logic.id,
            iri: 'http://test2.de'
          }
      end

      context 'change the record' do
        let!(:mapping_from_db) { LogicMapping.find_by_iri('http://test2.de') }

        it 'should exist' do
          expect(mapping_from_db).not_to be(nil)
        end

        it 'should have correct source' do
          expect(mapping_from_db.source).to eq(source_logic)
        end

        it 'should have correct target' do
          expect(mapping_from_db.target).to eq(target_logic)
        end
      end
    end

    context 'on POST to DELETE' do
      before { delete :destroy, id: mapping.to_param, logic_id: source_logic.id }

      it 'remove the record' do
        expect(LogicMapping.find_by_id(mapping.id)).to be(nil)
      end
    end

    context 'on GET to EDIT' do
      before { get :edit, id: mapping.to_param, logic_id: source_logic.id }
      it { should respond_with :success }
      it { should render_template :edit }

      it 'does not set the flash' do
        expect(flash).to be_empty
      end
    end
  end

  context 'signed in as not-owner' do
    let!(:user2) { create :user }
    before { sign_in user2 }

    context 'on get to show' do
      before { get :show, id: mapping.to_param, logic_id: source_logic.id }
      it { should respond_with :success }
      it { should render_template :show }

      it 'does not set the flash' do
        expect(flash).to be_empty
      end
    end

    context 'on get to new' do
      before { get :new, logic_id: source_logic.id }

      it { should respond_with :success }
      it { should render_template :new }
    end

    context 'on POST to CREATE' do
      before do
        post :create, logic_id: source_logic.id,
          logic_mapping: {
            source_id: source_logic.id,
            target_id: target_logic.id,
            iri: 'http://test.de'
          }
      end

      context 'create the record' do
        let!(:mapping_from_db) { LogicMapping.find_by_iri('http://test.de') }

        it 'should exist' do
          expect(mapping_from_db).not_to be(nil)
        end

        it 'should have correct source' do
          expect(mapping_from_db.source).to eq(source_logic)
        end

        it 'should have correct target' do
          expect(mapping_from_db.target).to eq(target_logic)
        end
      end
    end

    context 'on PUT to Update' do
      before do
        put :update, logic_id: source_logic.id, id: mapping.to_param,
          logic_mapping: {
            source_id: source_logic.id,
            target_id: target_logic.id,
            iri: 'http://test2.de'
          }
      end

      it 'not change the record' do
        expect(LogicMapping.find_by_iri('http://test2.de')).to be(nil)
      end
    end

    context 'on POST to DELETE' do
      before { delete :destroy, id: mapping.to_param, logic_id: source_logic.id }

      it 'not remove the record' do
        expect(LogicMapping.find_by_id(mapping.id)).to eq(mapping)
      end
    end

    context 'on GET to EDIT' do
      before { get :edit, id: mapping.to_param, logic_id: source_logic.id }
      it { should respond_with :redirect }

      it 'sets the flash' do
        expect(flash[:alert]).to match(/not authorized/)
      end
    end
  end

  context 'not signed in' do
    context 'on get to show' do
      before { get :show, id: mapping.to_param, logic_id: source_logic.id }
      it { should respond_with :success }
      it { should render_template :show }

      it 'does not set the flash' do
        expect(flash).to be_empty
      end
    end

    context 'on get to new' do
      before { get :new, logic_id: source_logic.id }

      it { should respond_with :redirect }

      it 'sets the flash' do
        expect(flash[:alert]).to match(/not authorized/)
      end
    end
  end

  context 'on POST to CREATE' do
    before do
      post :create, logic_id: source_logic.id,
        logic_mapping: {
          source_id: source_logic.id,
          target_id: target_logic.id,
          iri: 'http://test.de'
        }
    end

    it 'not create the record' do
      expect(LogicMapping.find_by_iri('http://test.de')).to be(nil)
    end
  end

  context 'on PUT to Update' do
    before do
      put :update, logic_id: source_logic.id, id: mapping.to_param,
        logic_mapping: {
          source_id: source_logic.id,
          target_id: target_logic.id,
          iri: 'http://test2.de'
        }
    end

    it 'not change the record' do
      expect(LogicMapping.find_by_iri('http://test2.de')).to be(nil)
    end
  end

  context 'on POST to DELETE' do
    before { delete :destroy, id: mapping.to_param, logic_id: source_logic.id }

    it 'not remove the record' do
      expect(LogicMapping.find_by_id(mapping.id)).to eq(mapping)
    end
  end
end
