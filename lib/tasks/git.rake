namespace :git do
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

    compile_gcc(source_file.to_s, target_path)
  end
end
