require 'spec_helper'

describe LogicsController do
  let!(:user) { create :user }
  let!(:logic) { create :logic, user: user }

  context 'on GET to show' do
    context 'requesting standard representation' do
      context 'not signed in' do
        before { get :show, id: logic.to_param }

        it { should respond_with :success }
        it { should render_template :show }
        it { should_not set_the_flash }
      end

      context 'signed in as Logic-Owner' do
        before do
          sign_in user
          get :show, id: logic.to_param
        end

        it { should respond_with :success }
        it { should render_template :show }
        it { should_not set_the_flash }
      end
    end

    context 'requesting json representation', api_specification: true do
      let(:logic_schema) { schema_for('logic') }

      before do
        get :show,
          id: logic.to_param,
          format: :json
      end

      it { should respond_with :success }

      it 'respond with json content type' do
        expect(response.content_type.to_s).to eq('application/json')
      end

      it 'should return a representation that validates against the schema' do
        VCR.use_cassette 'api/json-schemata/logic' do
          expect(response.body).to match_json_schema(logic_schema)
        end
      end
    end
  end

  context 'in GET to index' do
    before { get :index }

    it { should respond_with :success }
    it { should render_template :index }
    it { should_not set_the_flash }
  end

  context 'when requesting xml' do

    before do
      @request.env['HTTP_ACCEPT'] = 'text/xml'
      get :show, id: logic.slug
    end

    it 'should respond as a application/rdf+xml' do
      expect(response.content_type).to eq('application/rdf+xml')
    end
  end
end
