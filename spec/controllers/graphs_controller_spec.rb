require 'spec_helper'

describe GraphsController do
  let(:source) { create(:logic) }
  let(:target) { create(:logic) }
  let(:mapping) do
    create(:logic_mapping, source: source, target: target)
  end

  context 'on GET to index' do
    context 'valid on json-request' do
      before { get :index, logic_id: source, format: :json }

      it { should respond_with :success }
    end
    context 'valid on html-request' do
      before { get :index, logic_id: source, format: :html }

      it { should respond_with :success }
    end
    context 'valid response when there are no mappings' do
      let(:unlinked_source) { create(:logic) }
      before { get :index, logic_id: unlinked_source, format: :json }

      it { should respond_with :success }
    end
  end
end
