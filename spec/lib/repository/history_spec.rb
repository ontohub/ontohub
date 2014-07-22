require 'spec_helper'

describe "git history" do
  let(:userinfo) do
    {
      email: 'jan@jansson.com',
      name: 'Jan Jansson',
      time: Time.now
    }
  end

  context 'without bash' do
    let(:path) { '/tmp/ontohub/test/lib/repository' }
    let(:repository) { GitRepository.new(path) }

    after do
      FileUtils.rmtree(path) if File.exists?(path)
    end

    let(:filepath) { 'path/to/file.txt' }

    let!(:commit_add1)    { repository.commit_file(userinfo, 'Some content1', filepath, 'Add') }
    let!(:commit_change1) { repository.commit_file(userinfo, 'Some other content1', filepath, 'Change') }
    let!(:commit_other1)  { repository.commit_file(userinfo, 'Other content1', 'file2.txt', 'Other File: Add') }
    let!(:commit_delete1) { repository.delete_file(userinfo, filepath) }
    let!(:commit_other2)  { repository.commit_file(userinfo, 'Other content2', 'file2.txt', 'Other File: Change1') }
    let!(:commit_other3)  { repository.commit_file(userinfo, 'Other content3', 'file2.txt', 'Other File: Change2') }
    let!(:commit_add2)    { repository.commit_file(userinfo, 'Some content2', filepath, 'Re-Add') }
    let!(:commit_change2) { repository.commit_file(userinfo, 'Some other content2', filepath, 'Re-Change') }
    let!(:commit_delete2) { repository.delete_file(userinfo, filepath) }

    let!(:commits_all) do
      [
        commit_add1, commit_change1, commit_other1,
        commit_delete1, commit_other2, commit_other3, commit_add2,
        commit_change2, commit_delete2
      ].reverse
    end

    let!(:commits_file) do
      [
        commit_delete2, commit_change2, commit_add2,
        commit_delete1, commit_change1, commit_add1
      ]
    end

    context 'getting the commit history' do
      context 'list all commits in the branch' do
        it 'should make no difference between explicitly starting at HEAD or not specifying the start-oid' do
          expect(repository.commits(start_oid: commit_delete2)).
            to eq(repository.commits)
        end

        it 'should actually list all commits from HEAD to "init"' do
          expect(repository.commits.map(&:oid)).to eq(commits_all)
        end
      end

      context 'list only commits involving a file' do
        it 'should make no difference between explicitly starting at HEAD or not specifying the start-oid' do
          expect(repository.commits(start_oid: commit_delete2, path:filepath)).
            to eq(repository.commits(path: filepath))
        end

        it 'should actually list all commits involving that file' do
          expect(repository.commits(path: filepath).map(&:oid)).to eq(commits_file)
        end
      end

      context 'defining start and stop oids' do
        it 'should list all commits between start (included) and stop (excluded)' do
          expect(repository.commits(start_oid: commit_change2,
            stop_oid: commit_delete1).map(&:oid)).
            to eq([commit_change2, commit_add2, commit_other3, commit_other2])
        end

        it 'should list all commits between start (included) and stop (excluded) involving a file' do
          expect(repository.commits(start_oid: commit_change2,
            stop_oid: commit_delete1, path: filepath).map(&:oid)).
            to eq([commit_change2, commit_add2])
        end

        it 'should have the correct values in the history in the commit that changes another file' do
          expect(repository.commits(start_oid: commit_other3, path: filepath).map(&:oid)).
            to eq([commit_delete1, commit_change1, commit_add1])
        end
      end

      context 'passing a block' do
        it 'should return only the block result' do
          expect(repository.commits { |commit| commit.oid }).to eq(commits_all)
        end

        it 'should return only the block result involving a file' do
          expect(repository.commits(path: filepath) { |commit| commit.oid }).
            to eq(commits_file)
        end
      end

      context 'defining limit and offset' do
        it 'should have the correct commits with a limit lower than the commit count' do
          expect(repository.commits(limit: 3) { |commit| commit.oid }).
            to eq([commit_delete2, commit_change2, commit_add2])
        end

        it 'should have the correct commits with a limit higher than the commit count' do
          expect(repository.commits(limit: 30) { |commit| commit.oid }).
            to eq(commits_all)
        end

        it 'should have the correct commits with an offset and limit ending before reaching the "init" commit' do
          expect(repository.commits(limit: 3, offset: 2) { |commit| commit.oid }).
            to eq([commit_add2, commit_other3, commit_other2])
        end

        it 'should have the correct commits with an offset and limit ending at the "init" commit' do
          expect(repository.commits(limit: 3, offset: 6) { |commit| commit.oid }).
            to eq([commit_other1, commit_change1, commit_add1])
        end

        it 'should have the correct commits with an offset and limit ending after reaching the "init" commit' do
          expect(repository.commits(limit: 4, offset: 6) { |commit| commit.oid }).
            to eq([commit_other1, commit_change1, commit_add1])
        end

        context 'involving a file' do
          it 'should have the correct commits with a limit lower than the commit count' do
            expect(repository.commits(path: filepath, limit: 5) { |commit| commit.oid }).
              to eq([commit_delete2, commit_change2, commit_add2,
                commit_delete1, commit_change1])
          end

          it 'should have the correct commits with a limit same as the commit count' do
            expect(repository.commits(path: filepath, limit: 6) { |commit| commit.oid }).
              to eq(commits_file)
          end

          it 'should have the correct commits with a limit higher than the commit count' do
            expect(repository.commits(path: filepath, limit: 7) { |commit| commit.oid }).
              to eq(commits_file)
          end

          it 'should have the correct commits with an offset and limit ending after reaching the "init" commit' do
            expect(repository.commits(path: filepath, limit: 7, offset: 5) { |commit| commit.oid }).
              to eq([commit_add1])
          end
        end
      end
    end

    context 'state check' do
      it 'should detect that a file has not changed' do
        expect(repository.has_changed?(filepath, commit_add1, commit_add1)).
          to be_false
      end

      it 'should detect that a file has changed' do
        [ [commit_add1,    commit_change1],
          [commit_add1,    commit_delete1],
          [commit_delete1, commit_add2],
          [commit_delete1, commit_delete2] ].each do |previous, current|
          expect(repository.has_changed?(filepath, previous, current)).
            to be_true
        end
      end
    end
  end
end

describe 'git mv' do
  let(:userinfo) do
    {
      email: 'janjansson.com',
      name: 'Jan Jansson',
      time: Time.now
    }
  end

  let(:repository) { create :git_repository_with_moved_ontologies }

  after do
    repository.destroy
  end

  it 'should have all the commits' do
    # See script for details
    messages = ["add Px.clif", "add Qy.clif", "add Rz.clif",
      "move Px.clif to PxMoved.clif", "move PxMoved.clif to PxMoved2.clif",
      "move Qy.clif to QyMoved.clif, Rz.clif to RzMoved.clif"].map do |m|
        "#{m}\n"
      end.reverse

    expect(repository.commits{ |c| c.message }).to eq(messages)
  end

  context 'detect all the file renames' do
    it do
      expect(repository.commits(limit: 1, offset: 0) { |c| c.deltas }.first[0].
        status).to eq(:renamed)
    end

    it do
      expect(repository.commits(limit: 1, offset: 0) { |c| c.deltas }.first[0].
        old_file[:path]).to eq('Qy.clif')
    end

    it do
      expect(repository.commits(limit: 1, offset: 0) { |c| c.deltas }.first[0].
        new_file[:path]).to eq('QyMoved.clif')
    end


    it do
      expect(repository.commits(limit: 1, offset: 0) { |c| c.deltas }.first[1].
        status).to eq(:renamed)
    end

    it do
      expect(repository.commits(limit: 1, offset: 0) { |c| c.deltas }.first[1].
        old_file[:path]).to eq('Rz.clif')
    end

    it do
      expect(repository.commits(limit: 1, offset: 0) { |c| c.deltas }.first[1].
        new_file[:path]).to eq('RzMoved.clif')
    end


    it do
      expect(repository.commits(limit: 1, offset: 1) { |c| c.deltas }.first[0].
        status).to eq(:renamed)
    end

    it do
      expect(repository.commits(limit: 1, offset: 1) { |c| c.deltas }.first[0].
        old_file[:path]).to eq('PxMoved.clif')
    end

    it do
      expect(repository.commits(limit: 1, offset: 1) { |c| c.deltas }.first[0].
        new_file[:path]).to eq('PxMoved2.clif')
    end


    it do
      expect(repository.commits(limit: 1, offset: 2) { |c| c.deltas }.first[0].
        status).to eq(:renamed)
    end

    it do
      expect(repository.commits(limit: 1, offset: 2) { |c| c.deltas }.first[0].
        old_file[:path]).to eq('Px.clif')
    end

    it do
      expect(repository.commits(limit: 1, offset: 2) { |c| c.deltas }.first[0].
        new_file[:path]).to eq('PxMoved.clif')
    end
  end

end
