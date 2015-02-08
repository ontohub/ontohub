require 'spec_helper'

describe 'OntologyVersion - Proving' do
  setup_hets
  let(:user) { create :user }
  let(:parent_ontology) { create :distributed_ontology }

  before do
    parse_this(user, parent_ontology, hets_out_file('Simple_Implications'))
    stub_hets_for(prove_out_file('Simple_Implications'), command: 'prove', method: :post)
  end

  let(:ontology) { parent_ontology.children.find_by_name('Group') }
  let(:version) { ontology.current_version }

  context 'without exception' do
    before do
      version.async_prove
      Worker.drain
    end

    it 'should be done' do
      expect(ontology.reload.state).to eq('done')
    end
  end

  context 'on sidekiq shutdown' do
    before do
      allow(Hets).to receive(:prove_via_api).and_raise(Sidekiq::Shutdown)
      version.async_prove
      expect { Worker.drain }.to raise_error(Sidekiq::Shutdown)
    end

    it 'should reset status to pending' do
      expect(ontology.reload.state).to eq('pending')
    end
  end

  context 'on hets error' do
    before do
      allow(Hets).to receive(:prove_via_api).
        and_raise(Hets::HetsError, 'serious error')
      version.async_prove
      expect { Worker.drain }.to raise_error(Hets::HetsError)
    end

    it 'should set status to failed' do
      expect(ontology.reload.state).to eq('failed')
    end
  end

  context 'on failed to update state' do
    before do
      allow(Hets).to receive(:prove_via_api).
        and_raise(Hets::HetsError, 'first error')
      allow_any_instance_of(OntologyVersion).to receive(:after_failed).
        and_raise('second exception')
      version.async_prove
      expect { Worker.drain }.to raise_error(RuntimeError)
    end

    it 'should set status to failed on ontology' do
      expect(ontology.reload.state).to eq('failed')
    end

    it 'should set state to failed' do
      expect(version.reload.state).to eq('failed')
    end

    it 'should contain the nested error' do
      nested_error_regex = /nested exception.*second exception.*first error/im
      expect(version.reload.last_error).to match(nested_error_regex)
    end
  end
end
