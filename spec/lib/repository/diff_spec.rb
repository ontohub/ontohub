require 'spec_helper'

describe "git diff" do
  let(:path) { '/tmp/ontohub/test/lib/repository' }
  let(:repository) { GitRepository.new(path) }
  let(:userinfo) do
    {
      email: 'janjansson.com',
      name: 'Jan Jansson',
      time: Time.now
    }
  end

  after do
    FileUtils.rmtree(path) if File.exists?(path)
  end

  let (:content1)       { "Some\ncontent\nwith\nmany\nlines." }
  let (:content2)       { "Some\ncontent,\nwith\nmany\nlines." }
  let (:filepath_pn)    { Pathname.new 'path/to/file.xml' }
  let (:filepath)       { filepath_pn.to_s }
  let (:filename)       { filepath_pn.basename.to_s }
  let (:file_extension) { filepath_pn.extname[1..-1] }

  before do
    @commit1 = repository.commit_file(userinfo, content1, filepath.to_s, 'Message1')
    @commit2 = repository.commit_file(userinfo, content2, filepath.to_s, 'Message2')
    @commit3 = repository.delete_file(userinfo, filepath.to_s)
  end

  it 'should detect that the last commit is the HEAD' do
    expect(repository.is_head?(@commit3)).to be_true
  end

  it 'should have the right file count when using the first commit' do
    expect(repository.changed_files(@commit1).size).to eq(1)
  end

  it 'should have the right name in the list when using the first commit' do
    expect(repository.changed_files(@commit1).first.name).to eq(Pathname.new 'file.xml')
  end

  it 'should have the right path in the list when using the first commit' do
    expect(repository.changed_files(@commit1).first.path).to eq(filepath)
  end

  it 'should have the type added in the list when using the first commit' do
    expect(repository.changed_files(@commit1).first.added?).to be_true
  end

  %w(modified deleted renamed).each do |status|
    it "should have the type #{status} in the list when using the first commit" do
      expect(repository.changed_files(@commit1).first.send("#{status}?")).to be_false
    end
  end

  it 'should have the right mime type in the list when using the first commit' do
    expect(repository.changed_files(@commit1).first.mime_type).
      to eq(Mime::Type.lookup_by_extension(file_extension))
  end

  it 'should have the right mime category in the list when using the first commit' do
    expect(repository.changed_files(@commit1).first.mime_category).
      to eq('application')
  end

  it 'should have the right editable in the list when using the first commit' do
    expect(repository.changed_files(@commit1).first.editable?).to be_true
  end


  it 'should have the right file count when using a commit in the middle' do
    expect(repository.changed_files(@commit2).size).to eq(1)
  end

  it 'should have the right name in the list when using a commit in the middle' do
    expect(repository.changed_files(@commit2).first.name).to eq(Pathname.new filename)
  end

  it 'should have the right path in the list when using a commit in the middle' do
    expect(repository.changed_files(@commit2).first.path).to eq(filepath)
  end

  it 'should have the type modified in the list when using a commit in the middle' do
    expect(repository.changed_files(@commit2).first.modified?).to be_true
  end

  %w(added deleted renamed).each do |status|
    it "should have the type #{status} in the list when using a commit in the middle" do
      expect(repository.changed_files(@commit2).first.send("#{status}?")).to be_false
    end
  end

  it 'should have the right mime type in the list when using a commit in the middle' do
    expect(repository.changed_files(@commit2).first.mime_type).
      to eq(Mime::Type.lookup_by_extension(file_extension))
  end

  it 'should have the right mime category in the list when using a commit in the middle' do
    expect(repository.changed_files(@commit2).first.mime_category).
      to eq('application')
  end

  it 'should have the right editable in the list when using a commit in the middle' do
    expect(repository.changed_files(@commit2).first.editable?).to be_true
  end


  it 'should have the right file count when using the HEAD' do
    expect(repository.changed_files.size).to eq(1)
  end

  it 'should have the right name in the list when using the HEAD' do
    expect(repository.changed_files.first.name).to eq(Pathname.new filename)
  end

  it 'should have the right path in the list when using the HEAD' do
    expect(repository.changed_files.first.path).to eq(filepath)
  end

  it 'should have the type deleted in the list when using the HEAD' do
    expect(repository.changed_files.first.deleted?).to be_true
  end

  %w(added modified renamed).each do |status|
    it "should have the type #{status} in the list when using the HEAD" do
      expect(repository.changed_files.first.send("#{status}?")).to be_false
    end
  end

  it 'should have the right mime type in the list when using the HEAD' do
    expect(repository.changed_files.first.mime_type).
      to eq(Mime::Type.lookup_by_extension(file_extension))
  end

  it 'should have the right mime category in the list when using the HEAD' do
    expect(repository.changed_files.first.mime_category).to eq('application')
  end

  it 'should have the right editable in the list when using the HEAD' do
    expect(repository.changed_files.first.editable?).to be_true
  end
end
