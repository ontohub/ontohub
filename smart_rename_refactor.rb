#!/usr/bin/env ruby

require 'active_support'
require 'fileutils'
require 'pathname'

module Super

  AFFECTED_FILETYPES = %w[
    rb
    js
    coffee
    html
    haml
    erb
    css
    sass
    scss
    yml
  ]

  DIRECTORIES = %w[
    app
    config
    git
    lib
    spec
    test
  ]

  REPLACE_WORDS = {
    'entity' => 'symbol',
    'link' => 'mapping',
  }

  class RenameRefactorProvider
    include ActiveSupport::Inflector

    attr_accessor :verbose, :dry_run

    def initialize(verbose: false, dry_run: true)
      self.verbose = verbose
      self.dry_run = dry_run
    end

    def run
      REPLACE_WORDS.each { |old_word, new_word| replace old_word, new_word }
    end

    def replace(old_word, new_word)
      affected_files.each do |file|
        replace_in_file(file, old_word, new_word)
        rename_file(file, old_word, new_word)
      end
    end

    def replace_in_file(file, old_word, new_word)
      commands = [
        "gsub(\"#{old_word}\",\"#{new_word}\")",
        "gsub(\"#{pluralize(old_word)}\",\"#{pluralize(new_word)}\")",
        "gsub(\"#{camelize(old_word)}\",\"#{camelize(new_word)}\")",
        "gsub(\"#{camelize(pluralize(old_word))}\",\"#{camelize(pluralize(new_word))}\")",
      ]
      tmp_file = "> /tmp/awk_tmp_file && mv /tmp/awk_tmp_file #{file}"
      command = "#{awk} '{#{commands.join(';')};print}' #{file} #{tmp_file}"
      puts command if verbose
      system(command) unless dry_run
    end

    def rename_file(old_filename, old_word, new_word)
      new_filename = old_filename.gsub(/(?<=_|\b)(#{old_word}|#{pluralize(old_word)})/) do |match|
        match == old_word ? new_word : pluralize(new_word)
      end
      if new_filename != old_filename
        puts "#{old_filename} --> #{new_filename}" if verbose
        if !dry_run
          FileUtils.mkdir_p(File.dirname(new_filename))
          FileUtils.mv(old_filename, new_filename)
        end
      end
    end

    def affected_files
      filetype = AFFECTED_FILETYPES.first
      out = %x[find #{DIRECTORIES.join(' ')} -iname "*.#{filetype}" #{other_filetype_options}]
      files = out.lines.map { |l| l.delete("\n") }
    end

    def other_filetype_options
      AFFECTED_FILETYPES[1..-1].reduce('') do |options, filetype|
        options << "-o -iname \"*.#{filetype}\" "
      end
    end

    def awk
      'awk'
    end

  end

  class MigrationProvider
    include ActiveSupport::Inflector

    STRUCTURE_SQL_PATH = Pathname.new('db/structure.sql')

    attr_accessor :verbose, :dry_run, :migration_commands

    def initialize(verbose: false, dry_run: true)
      self.verbose = verbose
      self.dry_run = dry_run
      self.migration_commands = []
    end

    def run
      clean_slate unless dry_run
      sql_statements = read_structure_sql

      sql_statements.each do |sql_statement|
        rename_table(sql_statement)
      end

      puts migration_commands.map(&:inspect).join("\n") if dry_run && verbose
    end

    def clean_slate
      puts "Running rake db:migrate:clean" if verbose
      system('bundle exec rake db:migrate:clean')
    end

    def read_structure_sql
      STRUCTURE_SQL_PATH.readlines("\n\n\n").map do |command|
        command.lines.select do |line|
          !line.start_with?('--') && line != "\n"
        end.join("\n")
      end
    end

    def commands(sql_statements)
      sql_statements.map do |statement|
        statement.split(' ')[0..1].join(' ')
      end.uniq
    end

    def rename_table(sql_statement)
      if sql_statement =~ /^\s*CREATE TABLE (\S+)/
        old_name = $1
        new_name = translate(old_name)
        push(:change, "rename_table '#{old_name}', '#{new_name}'") if new_name
      end
    end

    def translate(name)
      REPLACE_WORDS.each do |old_name, new_name|
        result = case name
        when old_name
          new_name
        when pluralize(old_name)
          pluralize(new_name)
        when camelize(old_name)
          camelize(new_name)
        when camelize(pluralize(old_name))
          camelize(pluralize(new_name))
        end
        return result if result
      end
      nil
    end

    def push(*args)
      migration_commands << args
    end
  end
end

# Super::RenameRefactorProvider.new(verbose: false, dry_run: false).run
Super::MigrationProvider.new(verbose: true, dry_run: true).run
