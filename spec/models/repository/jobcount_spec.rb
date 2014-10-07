require 'spec_helper'

describe 'Repository saving (worker job count)' do
  let(:user)        { FactoryGirl.create :user }
  let(:repository)  { FactoryGirl.create :repository, user: user }

  let(:files) do {
      'inroot1.clif' => "(In1 Root)\n",
      'inroot1.clf' => "(In1 Root Too)\n",
      'inroot2.clif' => "(In2 Root)\n"
    }
  end
  let(:message) { 'test message' }

  it 'should get increased on saving first inroot1 file' do
    %w(inroot1.clif).each do |path|
      tmpfile = Tempfile.new(path)
      tmpfile.write(files[path])
      tmpfile.close

      repository.save_file(tmpfile.path, path, message, user)
    end
    expect(Worker.jobs.count).to eq(1)
  end

  it 'should not get increased on saving second inroot1 file' do
    %w(inroot1.clif inroot1.clf).each do |path|
      tmpfile = Tempfile.new(path)
      tmpfile.write(files[path])
      tmpfile.close

      repository.save_file(tmpfile.path, path, message, user)
    end
    expect(Worker.jobs.count).to eq(1)
  end

  it 'should get increased on saving inroot2 file after two inroot1 files' do
    %w(inroot1.clif inroot1.clf inroot2.clif).each do |path|
      tmpfile = Tempfile.new(path)
      tmpfile.write(files[path])
      tmpfile.close

      repository.save_file(tmpfile.path, path, message, user)
    end
    expect(Worker.jobs.count).to eq(2)
  end
end
