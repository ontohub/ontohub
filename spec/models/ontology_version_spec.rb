require 'spec_helper'

describe OntologyVersion do
  it { should belong_to :user }
  it { should belong_to :ontology }

  it { should have_db_index([:ontology_id, :number]) }
  it { should have_db_index(:user_id) }
  it { should have_db_index(:commit_oid) }
  it { should have_db_index(:checksum) }

  let(:user) { create :user }

  context 'OntologyVersion' do
    let(:ontology_version) { create :ontology_version }

    it 'should have a url' do
      version_url_regex = %r{
        http://example\.com/repositories/
        #{ontology_version.repository.path}/
        ontologies/\d+/versions/\d+$
      }x
      expect(ontology_version.url).to match(version_url_regex)
    end
  end

  context 'Parsing' do
    let(:ontology) { create :ontology, basepath: 'pizza' }
    let(:ontology_version) { ontology.save_file(ontology_file('owl/pizza.owl'), 'message', user) }

    before do
      # Clear Jobs
      Worker.jobs.clear
      stub_hets_for(hets_out_file('pizza'))
    end

    context 'in subdirectory' do
      let(:ontology) { create :ontology, basepath: 'subdir/pizza' }
      let(:qualified_locid) do
        "http://#{Settings.hostname}#{ontology_version.locid}"
      end

      before do
        ontology_version
        allow_any_instance_of(Hets::ParseCaller).to receive(:call) do |iri, *_args|
          throw(:iri, iri)
        end
      end

      it 'should use the locid-ref for calling the parse-caller' do
        expect { Worker.drain }.
          to throw_symbol(:iri, qualified_locid)
      end
    end

    context 'without exception' do
      let(:commit) { ontology_version.commit }

      before do
        # Run Job
        # binding.pry
        ontology_version
        Worker.drain
      end

      it 'should be done' do
        expect(ontology.reload.state).to eq('done')
      end

      it 'should have state_updated_at' do
        expect(ontology_version.state_updated_at).to_not be_nil
      end

      it 'should contain a commit' do
        expect(commit).to_not be_nil
      end

      it 'should contain a commit which refers to commit_oid' do
        expect(commit.commit_oid).to eq(ontology_version.commit_oid)
      end
    end

    context 'on sidekiq shutdown' do
      before do
        allow(Hets).to receive(:parse_via_api).and_raise(Sidekiq::Shutdown)
        ontology_version
        expect { Worker.drain }.to raise_error(Sidekiq::Shutdown)
      end

      it 'should reset status to pending' do
        expect(ontology.reload.state).to eq('pending')
      end
    end

    context 'on hets error' do
      before do
        allow(Hets).to receive(:parse_via_api).
          and_raise(Hets::HetsError, "serious error")
        ontology_version
        expect { Worker.drain }.to raise_error(Hets::HetsError)
      end

      it 'should set status to failed' do
        expect(ontology.reload.state).to eq('failed')
      end
    end

    context 'on failed to update state' do
      let(:ontology) { create :ontology, basepath: 'pizza' }
      let(:ontology_version) { ontology.save_file(ontology_file('owl/pizza.owl'), 'message', user) }

      before do
        allow(Hets).to receive(:parse_via_api).
          and_raise(Hets::HetsError, "first error")
        allow_any_instance_of(OntologyVersion).to receive(:after_failed).and_raise('second exception')
        ontology_version
        expect { Worker.drain }.to raise_error(RuntimeError)
      end

      it 'should set status to failed on ontology' do
        expect(ontology.reload.state).to eq('failed')
      end

      it 'should set state to failed' do
        expect(ontology_version.reload.state).to eq('failed')
      end

      it 'should contain the nested error' do
        nested_error_regex = /nested exception.*second exception.*first error/im
        expect(ontology_version.reload.last_error).to match(nested_error_regex)
      end

    end

  end
end
