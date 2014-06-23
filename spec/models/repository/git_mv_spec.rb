require 'spec_helper'

describe 'git mv', :process_jobs_synchronously do
  let(:userinfo) { {
      email: 'janjansson.com',
      name: 'Jan Jansson',
      time: Time.now
    } }

  let(:remote_repository) { create :git_repository_with_moved_ontologies }
  let(:repository) { create :repository,
    source_address: remote_repository.path, source_type: 'git' }

  after do
    remote_repository.destroy
  end

  it 'should detect ontology file renames' do
    expect(repository.ontologies.with_path('PxMoved2.clif').size).to eq(1)
    expect(repository.ontologies.with_path('PxMoved.clif').size).to eq(0)
    expect(repository.ontologies.with_path('Px.clif').size).to eq(0)

    expect(repository.ontologies.with_path('QyMoved.clif').size).to eq(1)
    expect(repository.ontologies.with_path('Qy.clif').size).to eq(0)

    expect(repository.ontologies.with_path('RzMoved.clif').size).to eq(1)
    expect(repository.ontologies.with_path('Rz.clif').size).to eq(0)
  end

  it 'should have only three ontologies' do
    expect(repository.ontologies.size).to eq(3)
  end

  it 'should create a version for each filename' do
    expect(repository.ontologies.with_path('PxMoved2.clif').first.
      versions.size).to eq(3)
    expect(repository.ontologies.with_path('QyMoved.clif').first.
      versions.size).to eq(2)
    expect(repository.ontologies.with_path('RzMoved.clif').first.
      versions.size).to eq(2)
  end
end
