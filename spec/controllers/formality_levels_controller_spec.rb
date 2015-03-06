require 'spec_helper'

describe FormalityLevelsController do

  let!(:formality_level)   { create :formality_level }

  context "signed in" do
    let(:user){ create(:user) }
    before { sign_in user }

    context "index" do
      before { get :index }
      it { should respond_with :success }
    end

    context "show" do
      context 'requesting standard representation' do
        before { get :show, id: formality_level.to_param }

        it { should respond_with :success }
        it { should render_template :show }
      end

      context 'requesting json representation', api_specification: true do
        let(:formality_level_schema) { schema_for('formality_level') }

        before do
          get :show,
            id: formality_level.to_param,
            format: :json
        end

        it { should respond_with :success }

        it 'respond with json content type' do
          expect(response.content_type.to_s).to eq('application/json')
        end

        it 'should return a representation that validates against the schema' do
          VCR.use_cassette 'api/json-schemata/formality_level' do
            expect(response.body).to match_json_schema(formality_level_schema)
          end
        end
      end
    end

    context "new" do
      before { get :new }
      it { should respond_with :found }
    end

    context "edit" do
      before { get :edit, id: formality_level.to_param }
      it { should respond_with :found }
    end

    context "create" do
      before { post :create }
      it { should respond_with :found }
    end

    context "update" do
      before { put :update, id: formality_level.to_param }
      it { should respond_with :found }
    end

    context "destroy" do
      before { delete :destroy, id: formality_level.to_param }
      it { should respond_with :found }
    end
  end

  context "not signed in" do
    context "index" do
      before { get :index }
      it { should respond_with :success }
    end

    context "show" do
      before { get :show, id: formality_level.id }
      it { should respond_with :success }
    end

    context "new" do
      before { get :new }
      it { should respond_with :found }
    end

    context "edit" do
      before { get :edit, id: formality_level.to_param }
      it { should respond_with :found }
    end

    context "create" do
      before { post :create }
      it { should respond_with :found }
    end

    context "update" do
      before { put :update, id: formality_level.to_param }
      it { should respond_with :found }
    end

    context "destroy" do
      before { delete :destroy, id: formality_level.to_param }
      it { should respond_with :found }
    end
  end

end
