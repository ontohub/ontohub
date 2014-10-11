require 'spec_helper'

describe GraphsController do
  let(:source) { FactoryGirl.create(:logic) }
  let(:target) { FactoryGirl.create(:logic) }
  let(:mapping) do
    FactoryGirl.create(:logic_mapping, source: source, target: target)
  end

  context 'on GET to index' do
    context 'valid on json-request' do
      before do
        get :index, logic_id: source, format: :json
      end

      it { should respond_with :success }
    end
    context 'valid on html-request' do
      before do
        get :index, logic_id: source, format: :html
      end

      it { should respond_with :success }
    end
    context 'valid response when there are no mappings/links' do
      let(:unlinked_source) { FactoryGirl.create(:logic) }
      before do
        get :index, logic_id: unlinked_source, format: :json
      end

      it { should respond_with :success }
    end
  end
end
