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

    context 'when pushing' do
      let(:repository) { create :repository }
      let(:bare_git) { create :git_repository_small_push }

      before do
        path = repository.local_path
        FileUtils.rm_r(path)
        FileUtils.mv(bare_git.path, path)
        Sidekiq::Testing.fake! do
          repository.suspended_save_ontologies(walk_order: Rugged::SORT_REVERSE)
        end
      end

      context 'a "small" push' do
        it 'shall receive priority' do
          job = OntologyBatchParseWorker.jobs.first
          expect(job['queue']).to eq('priority_push')
        end
      end

      context 'a "big" push' do
        let(:bare_git) { create :git_repository_big_push }

        it 'shall not receive priority' do
          job = OntologyBatchParseWorker.jobs.first
          expect(job['queue']).to_not eq('priority_push')
        end
      end
    end
  end
end
