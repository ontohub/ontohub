require 'spec_helper'

describe TeamsController do
  context 'not signed in' do
    context 'on GET to index' do
      before { get :index }

      it 'sets the flash' do
        expect(flash[:alert]).to match(/not authorized/)
      end
      it { expect(subject).to redirect_to(:root) }
    end
  end

  context 'signed in' do
    let(:user) { create :user }
    before { sign_in user }

    context 'on GET to index without teams' do
      before { get :index }

      it { expect(subject).to respond_with :success }
      it { expect(subject).to render_template :index }
    end

    context 'on GET to new' do
      before { get :new }

      it { expect(subject).to respond_with :success }
      it { expect(subject).to render_template :new }
    end

    context 'with teams' do
      let(:team) { create :team, admin_user: user }

      context 'on GET to index' do
        before { get :index }

        it { expect(subject).to respond_with :success }
        it { expect(subject).to render_template :index }
      end

      context 'on GET to show' do
        before { get :show, id: team.to_param }

        it { expect(subject).to respond_with :success }
        it { expect(subject).to render_template :show }
      end

      context 'on GET to edit' do
        before { get :edit, id: team.to_param }

        it { expect(subject).to respond_with :success }
        it { expect(subject).to render_template :edit }
      end

      context 'on DELETE to destroy' do
        context 'by team admin' do
          before { delete :destroy, id: team.id }

          it { expect(subject).to redirect_to(Team) }

          it 'sets the flash' do
            expect(flash[:notice]).to match(/destroyed/)
          end
        end

        context 'by non-admin' do
          let!(:member) { create :user }
          before do
            team.users << member
            sign_in member
            delete :destroy, id: team.id
          end

          it { expect(subject).to redirect_to(:root) }

          it 'sets the flash' do
            expect(flash[:alert]).to match(/not authorized/)
          end
        end
      end
    end
  end
end
