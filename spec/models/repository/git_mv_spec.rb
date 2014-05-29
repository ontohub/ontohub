require 'spec_helper'

describe 'git mv', :process_jobs_synchronously do
  TEMP_DIR = Pathname.new('/tmp/ontohub/test/models/')
  SCRIPT_CREATE_REPO_WITH_MOVED_ONTOLOGIES = Rails.root.
    join('spec', 'lib', 'repository', 'create_repository_with_moved_ontologies.sh')

  let(:userinfo) { {
      email: 'janjansson.com',
      name: 'Jan Jansson',
      time: Time.now
    } }

  let(:remote_path) { "file://#{TEMP_DIR.join('moved_ontologies', '.git')}" }
  let(:repository) { create :repository, source_address: remote_path, source_type: 'git' }

  before do
    FileUtils.mkdir_p(TEMP_DIR)
    Dir.chdir(TEMP_DIR) { `#{SCRIPT_CREATE_REPO_WITH_MOVED_ONTOLOGIES}` }
  end

  after do
    FileUtils.rmtree TEMP_DIR
  end

  it 'should detect ontology file renames' do
    expect(repository.ontologies.find_with_path('PxMoved2.clif').size).to eq(1)
    expect(repository.ontologies.find_with_path('PxMoved.clif').size).to eq(0)
    expect(repository.ontologies.find_with_path('Px.clif').size).to eq(0)

    expect(repository.ontologies.find_with_path('QyMoved.clif').size).to eq(1)
    expect(repository.ontologies.find_with_path('Qy.clif').size).to eq(0)

    expect(repository.ontologies.find_with_path('RzMoved.clif').size).to eq(1)
    expect(repository.ontologies.find_with_path('Rz.clif').size).to eq(0)
  end

  it 'should have only three ontologies' do
    expect(repository.ontologies.size).to eq(3)
  end

  it 'should create a version for each filename' do
    expect(repository.ontologies.find_with_path('PxMoved2.clif').first.
      versions.size).to eq(3)
    expect(repository.ontologies.find_with_path('QyMoved.clif').first.
      versions.size).to eq(2)
    expect(repository.ontologies.find_with_path('RzMoved.clif').first.
      versions.size).to eq(2)
  end
end
