namespace :git do
  def reconfigure_cp_keys(source_file)
    data_root = Ontohub::Application.config.data_root
    git_home = Ontohub::Application.config.git_home

    reconfigured_source = File.read(source_file).
      sub(/^#define DATA_ROOT .*$/, "#define DATA_ROOT \"#{data_root}\"").
      sub(/^#define GIT_HOME .*$/, "#define GIT_HOME \"#{git_home}\"")

    reconfigured_source_file = Tempfile.new(%w(cp_keys .c))
    reconfigured_source_file.write(reconfigured_source)
    reconfigured_source_file.close
    puts "Copying #{source_file} to tempfile #{reconfigured_source_file.path}"
    puts "Reconfiguring DATA_ROOT in this tempfile to #{data_root}"
    puts "Reconfiguring GIT_HOME in this tempfile to #{git_home}"

    reconfigured_source_file
  end

  def compile_gcc(source_path, target_path)
    command = ['gcc', source_path, '-o', target_path]
    puts "Compiling #{target_path.split('/').last} with"
    puts command.map { |c| c.match(/\s/) ? "'#{c}'" : c }.join(' ')
    system(*command)
  end

  desc 'Compile cp_keys binary'
  task :compile_cp_keys => :environment do
    source_file = Rails.root.join('script', 'cp_keys.c')
    target_path = Rails.root.join('bin', 'cp_keys').to_s

    reconfigured_source_tempfile = reconfigure_cp_keys(source_file)
    compile_gcc(reconfigured_source_tempfile.path, target_path)
    reconfigured_source_tempfile.unlink
  end
end
