require 'open3'

module GitRepository::Cloning
  extend ActiveSupport::Concern

  module ClassMethods
    def clone_git(source, target_path, depth=nil)
      if depth.nil? || depth == 0
        stdin, stdout, stderr, wait_thr = Open3.popen3 'git', 'clone', '--bare', source, target_path
      else
        stdin, stdout, stderr, wait_thr = Open3.popen3 'git', 'clone', '--bare', source, target_path, '--depth', "#{depth}"
      end

      { out: stdout.gets(nil), err: stderr.gets(nil), success: wait_thr.value.success? }
    end

    def clone_svn(source, target_path)
      target_path = target_path[0..-2] if target_path[-1] == '/'
      target_path_svn = target_path_svn_base = "#{target_path}_svn"

      if File.exists? target_path
        { out: nil, err: "#{target_path} already exists.", success: false}
      else
        i = 0
        while File.exists? target_path_svn do
          target_path_svn = "#{target_path_svn_base}#{i}"
          i = i+1
        end

        stdin, stdout, stderr, wait_thr = Open3.popen3 'git', 'svn', 'clone', '-r', 'HEAD', source, target_path_svn
        out = stdout.gets(nil)
        err = stderr.gets(nil)
        if wait_thr.value.success?
          result = GitRepository.clone_git(target_path_svn, target_path)
          FileUtils.rmtree target_path_svn

          result
        else
          { out: out, err: err, success: false }
        end
      end
    end

  end
end
