require 'spec_helper'

describe Repository::Symlinks do
  context 'public repository' do
    let(:repository) { create :repository }

    shared_examples 'symlink_creation' do |category|
      let(:link_path) { repository.symlink_path(category) }
      let(:link_target) { File.readlink(link_path) }

      it "symlink for #{category} created" do
        expect(link_target).to eq(repository.local_path.to_s)
      end

      context 'repository destroy' do
        before { repository.destroy }

        it "symlink for #{category} removed" do
          expect(repository.symlink_path(category).exist?).to be(false)
        end
      end
    end

    include_examples('symlink_creation', :git_daemon)
    include_examples('symlink_creation', :git_ssh)

    context 'made private' do
      before do
        repository.access = 'private_rw'
        repository.save!
      end

      it 'deletes the git_daemon symlink' do
        expect(repository.symlink_path(:git_daemon).exist?).to be(false)
      end

      it 'keeps the git_ssh symlink' do
        expect(repository.symlink_path(:git_ssh).exist?).to be(true)
      end
    end
  end

  context 'private repository' do
    let(:repository) { create :repository, access: 'private_rw' }

    context 'git_daemon' do
      let(:category) { :git_daemon }
      let(:link_path) { repository.symlink_path(category) }
      let(:link_target) { File.readlink(link_path) }

      it "symlink for git_daemon not created" do
        expect(repository.symlink_path(category).exist?).to be(false)
      end

      context 'made public' do
        before do
          repository.access = 'public_r'
          repository.save!
        end

        it 'creates the symlink' do
          expect(repository.symlink_path(category).exist?).to be(true)
        end
      end

      context 'repository destroy' do
        before { repository.destroy }

        it "symlink for git_daemon removed" do
          expect(repository.symlink_path(category).exist?).to be(false)
        end
      end
    end

    context 'git_ssh' do
      let(:category) { :git_ssh }
      let(:link_path) { repository.symlink_path(category) }
      let(:link_target) { File.readlink(link_path) }

      it "symlink for git_ssh created" do
        expect(link_target).to eq(repository.local_path.to_s)
      end

      context 'repository destroy' do
        before { repository.destroy }

        it "symlink for git_ssh removed" do
          expect(repository.symlink_path(category).exist?).to be(false)
        end
      end
    end
  end
end
