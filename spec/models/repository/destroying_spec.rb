require 'spec_helper'

describe 'Repository destroying' do
  let(:repository) { create :repository }

  before do
    repository.destroy_asynchronously
  end

  it 'should create a job' do
    expect(Worker.jobs.size).to eq(1)
  end

  it 'should mark the repository as destroying' do
    expect(repository.destroying).to be_truthy
  end
end
