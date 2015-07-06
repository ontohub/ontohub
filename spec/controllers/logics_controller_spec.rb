require 'spec_helper'

describe LogicsController do
  let!(:user) { create :user }
  let!(:logic) { create :logic, user: user }

  context 'on GET to show' do
    context 'requesting standard representation' do
      context 'not signed in' do
        before { get :show, id: logic.to_param }

        it { expect(subject).to respond_with :success }
        it { expect(subject).to render_template :show }

        it 'does not set the flash' do
          expect(flash).to be_empty
        end
      end

      context 'signed in as Logic-Owner' do
        before do
          sign_in user
          get :show, id: logic.to_param
        end

        it { expect(subject).to respond_with :success }
        it { expect(subject).to render_template :show }

        it 'does not set the flash' do
          expect(flash).to be_empty
        end
      end
    end
  end

  context 'in GET to index' do
    before { get :index }

    it { expect(subject).to respond_with :success }
    it { expect(subject).to render_template :index }

    it 'does not set the flash' do
      expect(flash).to be_empty
    end
  end
end
