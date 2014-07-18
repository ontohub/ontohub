require 'spec_helper'

describe GitRepository do

  ENV['LANG'] = 'C'

  context 'creating and deleting a repository' do
    let(:path) { Rails.root.join('tmp', 'test', 'unit', 'git_repository').to_s }

    after do
      FileUtils.rmtree(path) if File.exists?(path)
    end

    context 'create repository' do

      it 'should not exist before creation' do
        expect(File.exists?(path)).to be_false
      end

      context 'after creation' do
        let(:repository_new) { GitRepository.new(path) }

        before { repository_new } # access it to create it

        it { expect(File.exists?(path)).to be_true }
        it { expect(repository_new.empty?).to be_true }

        context 'deletion' do
          before { repository_new.destroy }
          it { expect(File.exists?(path)).to be_false }
        end
      end
    end
  end
end
