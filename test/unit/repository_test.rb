require 'test_helper'

class RepositoryTest < ActiveSupport::TestCase

  should have_many :ontologies
  should have_many :permissions

  context "a repository" do
    setup do
      @user       = FactoryGirl.create :user
      @repository = FactoryGirl.create :repository, user: @user
    end

    teardown do
      @repository.destroy
    end

    context 'with a reserved name' do
      should 'not be valid' do
        repository = FactoryGirl.build :repository, user: @user, name: 'repositories'
        assert repository.invalid?
        assert repository.errors[:name].any?
      end
    end

    context 'creating a permission' do
      setup do
        assert_not_nil @permission = @repository.permissions.first
      end

      should 'with subject' do
        assert_equal @user, @permission.subject
      end

      should 'with role owner' do
        assert_equal 'owner', @permission.role
      end
    end

    context 'made private' do
      setup do
        @repository.access = 'private_rw'
        @repository.save

        editor = FactoryGirl.create :user
        readers = [FactoryGirl.create(:user), FactoryGirl.create(:user), FactoryGirl.create(:user)]

        FactoryGirl.create(:permission, subject: editor, role: 'editor', item: @repository)
        readers.each { |r| FactoryGirl.create(:permission, subject: r, role: 'reader', item: @repository) }
      end

      should 'not clear reader premissions when saved, but not set public' do
        assert_equal 3, @repository.permissions.where(role: 'reader').count
        @repository.name += "_foo"
        @repository.save
        assert_equal 3, @repository.permissions.where(role: 'reader').count
      end

      should 'clear reader premissions when set public' do
        assert_equal 3, @repository.permissions.where(role: 'reader').count
        @repository.access = 'public_r'
        @repository.save
        assert_equal 0, @repository.permissions.where(role: 'reader').count
      end
    end

    context 'saving a file' do
      setup do
        @file_path = '/tmp/ontohub/test/git_repository/save_file.txt'
        @target_path = 'save_file.clif'
        @message = 'test message'
        @content = "(Cat x)\n"

        # create directory if it doesn't exist
        dir = File.dirname(@file_path)
        unless File.directory?(dir)
          FileUtils.mkdir_p(dir)
        end

        # create file
        tmpfile = File.open(@file_path, 'w')
        tmpfile.puts(@content)
        tmpfile.close
      end

      should 'not have an ontology yet' do
        assert_equal @repository.ontologies.count, 0
      end

      context "that doesn't exist" do
        setup do
          @version = @repository.save_file(@file_path, @target_path, @message, @user)
        end

        should 'create the file in the git repository' do
          assert @repository.git.path_exists?(@target_path)
        end

        should 'create the file with correct contents in the git repository' do
          assert_equal @content, @repository.git.get_file(@target_path)[:content]
        end

        should 'create a new ontology with a default name' do
          assert_equal @repository.ontologies.count, 1
          assert_equal @repository.ontologies.first.name, 'Save_file'
        end

        should 'create a new ontology with only one version pointing to the commit' do
          o = @repository.ontologies.first
          assert_equal o.versions.count, 1
          assert_equal o.versions.first[:commit_oid], @version.commit_oid
        end

        should 'create a new ontology with only one version belonging to the right user' do
          v = @repository.ontologies.first.versions.first
          assert_equal v.user, @user
        end
      end

      context 'that exists' do
        setup do
          assert_difference 'Worker.jobs.count' do
            @repository.save_file(@file_path, @target_path, @message, @user)
          end

          file = File.open(@file_path, 'w')
          file.puts("#{@content}\n#{@content}")
          file.close

          @repository.save_file(@file_path, @target_path, @message, @user)
        end

        teardown do
          @repository.destroy
        end

        should 'create a new ontology version' do
          ontology = @repository.ontologies.where(basepath: File.basepath(@target_path)).first!
          assert_equal 2, ontology.versions.count
        end
      end
    end

    context 'browsing the repository' do
      setup do
        @files = {
          'inroot1.clif' => "(In1 Root)\n",
          'inroot2.clf' => "(In2 Root Too)\n",
          'inroot2.clif' => "(In2 Root Too2)\n",
          'folder1/file1.clif' => "(In Folder)\n",
          'folder1/file2.clf' => "(In2 Folder Too)\n",
          'folder2/file3.clf' => "(In2 Folder Again)\n"
        }
        @message = 'test message'
        @file_path_prefix = '/tmp/ontohub/test/git_repository/'
        @iri_prefix = 'http://localhost/repo_name/'
        @files.each do | path, content |
          file_path = "#{@file_path_prefix}#{path}"

          # create directory if it doesn't exist
          dir = File.dirname(file_path)
          unless File.directory?(dir)
            FileUtils.mkdir_p(dir)
          end

          # create file
          tmpfile = File.open(file_path, 'w')
          tmpfile.puts(content)
          tmpfile.close

          if path == 'inroot2.clif'
            assert_no_difference 'Worker.jobs.count' do
              @repository.save_file(file_path, path, @message, @user, "#{@iri_prefix}#{file_path}")
            end
          else
            assert_difference 'Worker.jobs.count' do
              @repository.save_file(file_path, path, @message, @user, "#{@iri_prefix}#{file_path}")
            end
          end
        end
      end

      teardown do
        @repository.destroy
      end

      should 'list files and directories in the directories' do
        assert_equal @repository.path_info, @repository.path_info('/')
        %w{/ folder1 folder2}.each do |folder|
          assert_equal :dir, @repository.path_info(folder)[:type]
        end
        assert_equal 4, @repository.path_info('/')[:entries].size
        assert_equal 2, @repository.path_info('folder1')[:entries].size
        assert_equal 1, @repository.path_info('folder2')[:entries].size

        path_infos_entries = @repository.path_info('/')[:entries]
        assert_equal 4, path_infos_entries.size

        selected_entry = path_infos_entries["folder1"]
        assert_equal [{
            :type=>:dir,
            :name=>"folder1",
            :path=>"folder1",
            :index=>0,
            :ontologies => []
          }], selected_entry

        selected_entry = path_infos_entries["inroot2"]
        assert_equal [
                {:type=>:file, :name=>"inroot2.clf", :path=>"inroot2.clf", :index=>3},
                {:type=>:file, :name=>"inroot2.clif", :path=>"inroot2.clif", :index=>4}
              ], selected_entry.map{ |e| e.except(:ontologies) }
        assert_equal(['Inroot2'], selected_entry.map{ |e| e[:ontologies].map(&:to_s) }.flatten)

        path_infos_entries = @repository.path_info('folder2')[:entries]
        assert_equal 1, path_infos_entries.size
        selected_entry = path_infos_entries["file3"]
        assert_equal([{:type=>:file, :name=>"file3.clf", :path=>"folder2/file3.clf", :index=>0}],
          selected_entry.map{ |e| e.except(:ontologies) })
        assert_equal(['File3'], selected_entry.map{ |e| e[:ontologies].map(&:to_s) }.flatten)
      end

      should 'list files with given basename' do
        expected = {
          type: :file_base,
          entry: {:type=>:file, :name=>"inroot1.clif", :path=>"inroot1.clif"}
        }
        assert_equal expected, @repository.path_info('inroot1')

        expected = {
          type: :file_base_ambiguous,
          entries: [
              {:type=>:file, :name=>"inroot2.clf", :path=>"inroot2.clf"},
              {:type=>:file, :name=>"inroot2.clif", :path=>"inroot2.clif"}
            ]
        }
        assert_equal expected, @repository.path_info('inroot2')
      end

      should 'have type file on exact filename' do
        @files.each do |path, content|
          assert_equal :file, @repository.path_info(path)[:type]
          assert_equal path.split('/')[-1], @repository.path_info(path)[:file][:name]
          assert_equal content.size, @repository.path_info(path)[:file][:size]
          assert_equal content, @repository.path_info(path)[:file][:content]
        end
      end

      should 'be nil on non-existent file/folder' do
        assert_nil @repository.path_info('dolfer1')
      end

      should 'paths_starting_with?' do
        assert_equal(['inroot2.clf', 'inroot2.clif'], @repository.paths_starting_with('inroot2'))
        assert_equal(['inroot1.clif', 'inroot2.clf', 'inroot2.clif'],
          @repository.paths_starting_with('inroot'))

        assert_equal(['folder1/file1.clif', 'folder1/file2.clf'],
          @repository.paths_starting_with('folder1/file'))
      end

      should 'dir?' do
        assert !@repository.dir?('non-existent')
        assert !@repository.dir?('inroot1.clif')
        assert @repository.dir?('folder1')
      end
    end
  end

end
