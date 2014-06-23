require 'spec_helper'

describe 'git mv', :process_jobs_synchronously do
  let(:userinfo) do
    {
      email: 'janjansson.com',
      name: 'Jan Jansson',
      time: Time.now
    }
  end

  let(:remote_repository) { create :git_repository_with_moved_ontologies }
  let(:repository) { create :repository,
    source_address: remote_repository.path, source_type: 'git' }

  after do
    remote_repository.destroy
  end

  context 'should detect ontology file renames' do
    it { expect(repository.ontologies.with_path('PxMoved2.clif').size).to eq(1) }
    it { expect(repository.ontologies.with_path('PxMoved.clif').size).to eq(0) }
    it { expect(repository.ontologies.with_path('Px.clif').size).to eq(0) }

    it { expect(repository.ontologies.with_path('QyMoved.clif').size).to eq(1) }
    it { expect(repository.ontologies.with_path('Qy.clif').size).to eq(0) }

    it { expect(repository.ontologies.with_path('RzMoved.clif').size).to eq(1) }
    it { expect(repository.ontologies.with_path('Rz.clif').size).to eq(0) }
  end

  context 'should have only three ontologies' do
    it { expect(repository.ontologies.size).to eq(3) }
  end

  context 'should create a version for each filename' do
    it do
      expect(repository.ontologies.with_path('PxMoved2.clif').first.
        versions.size).to eq(3)
    end

    it do
      expect(repository.ontologies.with_path('QyMoved.clif').first.
        versions.size).to eq(2)
    end

    it do
      expect(repository.ontologies.with_path('RzMoved.clif').first.
        versions.size).to eq(2)
    end
  end
end
