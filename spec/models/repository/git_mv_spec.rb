require 'spec_helper'

describe 'git mv', :process_jobs_synchronously, :example_uses_transaction do
  setup_hets

  let(:userinfo) do
    {
      email: 'janjansson.com',
      name: 'Jan Jansson',
      time: Time.now
    }
  end

  let(:remote_repository) { create :git_repository_with_moved_ontologies }
  let(:repository) do
    create :repository_git_mirror, source_address: remote_repository.path
  end

  before do
    stub_hets_for('clif/Px.clif', with: 'Px')
    stub_hets_for('clif/Qy.clif', with: 'Qy')
    stub_hets_for('clif/Rz.clif', with: 'Rz')
  end

  after do
    remote_repository.destroy
  end

  context 'should detect ontology file renames' do
    it 'PxMoved2.clif' do
      expect(repository.ontologies.with_path('PxMoved2.clif').size).to eq(1)
    end

    it 'PxMoved.clif' do
      expect(repository.ontologies.with_path('PxMoved.clif').size).to eq(0)
    end

    it 'Px.clif' do
      expect(repository.ontologies.with_path('Px.clif').size).to eq(0)
    end

    it 'QyMoved.clif' do
      expect(repository.ontologies.with_path('QyMoved.clif').size).to eq(1)
    end

    it 'Qy.clif' do
      expect(repository.ontologies.with_path('Qy.clif').size).to eq(0)
    end

    it 'RzMoved.clif' do
      expect(repository.ontologies.with_path('RzMoved.clif').size).to eq(1)
    end

    it 'Rz.clif' do
      expect(repository.ontologies.with_path('Rz.clif').size).to eq(0)
    end
  end

  it 'should have only three ontologies' do
    expect(repository.ontologies.size).to eq(3)
  end

  context 'should create a version for each filename' do
    it 'PxMoved2.clif' do
      expect(repository.ontologies.with_path('PxMoved2.clif').first.
        versions.size).to eq(3)
    end

    it 'QyMoved.clif' do
      expect(repository.ontologies.with_path('QyMoved.clif').first.
        versions.size).to eq(2)
    end

    it 'RzMoved.clif' do
      expect(repository.ontologies.with_path('RzMoved.clif').first.
        versions.size).to eq(2)
    end
  end
end
