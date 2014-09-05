require 'spec_helper'

describe PermissionsController do
  let(:owner)      { create :user }
  let(:permission) { create(:permission, subject: owner, role: 'owner') }

  before { sign_in owner }

  ERROR_TEXT = "You can't remove this owner permission"

  describe 'owner degradation' do
    context 'one owner' do
      render_views

      context 'should display an error message on delete' do
        before do
          request.env["HTTP_REFERER"] = repository_permissions_url(repository_id: permission.item.to_param)
          delete :destroy, repository_id: permission.item.to_param, id: permission.id
        end

        it 'and redirect' do
          expect(response).to redirect_to [permission.item, :permissions]
        end

        it '(have the error message in flash hash)' do
          expect(flash[:alert]).to have_content(ERROR_TEXT)
        end
      end

      it 'should render an error message on degrading update' do
        put :update, repository_id: permission.item.to_param, id: permission.id,
          permission: {id: permission.id, role: 'editor'}
        expect(response.body).to have_content(ERROR_TEXT)
      end

      %w(editor reader).each do |role|
        it "should be possible to remove another (#{role}) permission" do
          other_permission = create(:permission, subject: owner, role: role)
          delete :destroy, repository_id: other_permission.item.to_param, id: other_permission.id
          expect(response.body).not_to have_content(ERROR_TEXT)
        end
      end
    end

    context 'many owners' do
      let(:other_owner)      { create(:user) }
      before do
        create(:permission, subject: other_owner, role: 'owner', item: permission.item)
      end

      context 'should be possible to remove one' do
        before do
          request.env["HTTP_REFERER"] = repository_permissions_url(repository_id: permission.item.to_param)
          delete :destroy, repository_id: permission.item.to_param, id: permission.id
        end

        it 'should redirect' do
          expect(response).to redirect_to [permission.item, :permissions]
        end

        it 'should not have an error message in flash hash' do
          expect(flash[:alert]).not_to have_content(ERROR_TEXT)
        end
      end

      it 'should be possible to degrade his role' do
        put :update, repository_id: permission.item.to_param, id: permission.id,
          permission: { id: permission.id, role: 'editor' }
        expect(response.body).not_to have_content(ERROR_TEXT)
      end
    end
  end
end
