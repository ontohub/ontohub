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
    MIGRATION_DIRPATH  = Pathname.new('db/migrate')

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
        rename_columns(sql_statement)
        rename_table(sql_statement)
        rebuild_index(sql_statement)
        rename_in_function(sql_statement)
        rename_primary_keys(sql_statement)
        rebuild_foreign_keys(sql_statement)
      end

      puts migration_commands.map(&:inspect).join("\n") if dry_run && verbose
      write_migration
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

    def rename_in_function(sql_statement)
      if m = sql_statement.match(/^\s*CREATE FUNCTION (?<signature>.+?\))(?<header>.+?)(\s*LANGUAGE (?<language>.+?))\s*AS\s+(?<name>.+?)\s*BEGIN\s+(?<body>.+?)\s*END;/m)

        translated = [m[:signature],m[:header], m[:name], m[:body]].map { |t| translate t }
        if translated.any?
          new_signature = translate(m[:signature]) || m[:signature]
          new_header = translate(m[:header]) || m[:header]
          new_name = translate(m[:name]) || m[:name]
          new_body = translate(m[:body]) || m[:body]

          drop_old_function = <<-DROP_FUNCTION
      DROP FUNCTION #{m[:signature]};
    DROP_FUNCTION

          drop_new_function = <<-DROP_FUNCTION
      DROP FUNCTION #{new_signature};
    DROP_FUNCTION

          create_old_function = <<-CREATE_FUNCTION
      CREATE OR REPLACE FUNCTION #{m[:signature]}
      #{m[:header]} AS #{m[:name]}
      BEGIN
      #{m[:body]}
      END;
      #{m[:name]} language #{m[:language]};
    CREATE_FUNCTION

          create_new_function = <<-CREATE_FUNCTION
      CREATE OR REPLACE FUNCTION #{new_signature}
      #{new_header} AS #{m[:name]}
      BEGIN
      #{new_body}
      END;
      #{new_name} language #{m[:language]};
    CREATE_FUNCTION

          push(:up, "execute <<-SQL\n#{drop_old_function}    SQL\n")
          push(:up, "execute <<-SQL\n#{create_new_function}    SQL\n")

          push(:down, "execute <<-SQL\n#{drop_new_function}    SQL\n")
          push(:down, "execute <<-SQL\n#{create_old_function}    SQL\n")
        end
      end
    end

    def rename_table(sql_statement)
      if sql_statement =~ /^\s*CREATE TABLE (\S+)/
        old_name = $1
        if new_name = translate(old_name)
          push(:up, "rename_table '#{old_name}', '#{new_name}'")
          push(:down, "rename_table '#{new_name}', '#{old_name}'")
        end
      end
    end

    def rename_columns(sql_statement)
      if sql_statement =~ /^\s*CREATE TABLE (\S+)/
        table_name = $1
        sql_statement.lines[1..-2].each do |column_line|
          if column_line =~ /^\s+(\S+)\s+/
            column_name = $1
            if new_column_name = translate(column_name)
              push(:up, "rename_column '#{table_name}', '#{column_name}', '#{new_column_name}'")
              push(:down, "rename_column '#{table_name}', '#{new_column_name}', '#{column_name}'")
            end
          end
        end
      end
    end

    def rebuild_index(sql_statement)
      if m = sql_statement.match(/^\s*CREATE (?<unique>UNIQUE )?INDEX (?<index_name>\S+) ON (?<table_name>\S+) USING btree \((?<columns_list>([^,\s]+, )*(\S+))\)/)
        unique = !! m['unique']

        old_index_name = m['index_name']
        new_index_name = translate(old_index_name)
        index_name = new_index_name || old_index_name

        old_table_name = m['table_name']
        new_table_name = translate(old_table_name)
        table_name = new_table_name || old_table_name

        old_columns = m['columns_list'].split(', ')
        new_columns = old_columns.map{ |c| translate(c) }

        old_column_names = old_columns.map{ |c| "'#{c}'"}.join(', ')
        column_names = old_columns.map{ |c| "'#{translate(c) || c}'" }.join(', ')

        if [new_index_name, new_table_name, *new_columns].any?
          # At this point, the index is already on the new table, but with the old name
          push(:up, "remove_index '#{table_name}', name: '#{old_index_name}'")
          push(:down, "add_index '#{old_table_name}', [#{old_column_names}], unique: #{unique}, name: '#{old_index_name}'")

          push(:up, "add_index '#{table_name}', [#{column_names}], unique: #{unique}, name: '#{index_name}'")
          push(:down, "remove_index '#{old_table_name}', name: '#{index_name}'")
        end
      end
    end

    def rename_primary_keys(sql_statement)
      if m = sql_statement.match(/ALTER TABLE ONLY (?<table>\S+)\s*ADD CONSTRAINT (?<name>\S+)\s+PRIMARY KEY/)

        table = translate(m[:table]) || m[:table]
        new_name = translate(m[:name])

        if new_name
          push(:up,   "execute \"ALTER TABLE ONLY #{table} RENAME CONSTRAINT #{m[:name]} TO #{new_name};\"")
          push(:down, "execute \"ALTER TABLE ONLY #{table} RENAME CONSTRAINT #{new_name} TO #{m[:name]};\"")
        end
      end
    end

    def rebuild_foreign_keys(sql_statement)
      if m = sql_statement.match(/ALTER TABLE ONLY (?<table>\S+)\s*ADD CONSTRAINT (?<name>\S+)\s+FOREIGN KEY \((?<key>\S+)\)\s+REFERENCES (?<ref>\S+\(\S+\))(?<ondelete>[^\n]*)/)

        table = translate(m[:table]) || m[:table]
        new_name = translate(m[:name]) || m[:name]
        new_key = translate(m[:key]) || m[:key]
        new_ref = translate(m[:ref]) || m[:ref]

        translated = [m[:name], m[:key], m[:ref]].map { |t| translate(t) }

        if translated.any?
          push(:up,   "execute \"ALTER TABLE ONLY #{table} DROP CONSTRAINT #{m[:name]};\"")
          push(:up,   "execute \"ALTER TABLE ONLY #{table} ADD CONSTRAINT #{new_name} FOREIGN KEY (#{new_key}) REFERENCES #{new_ref}#{m[:ondelete]}\"")

          push(:down, "execute \"ALTER TABLE ONLY #{table} DROP CONSTRAINT #{new_name};\"")
          push(:down, "execute \"ALTER TABLE ONLY #{table} ADD CONSTRAINT #{m[:name]} FOREIGN KEY (#{m[:key]}) REFERENCES #{m[:ref]}#{m[:ondelete]}\"")
        end
      end
    end

    def write_migration
      migration_filepath.open('w') do |f|
        f << "class RenameViaScript < ActiveRecord::Migration\n"
        migration_commands.group_by{ |c| c.first }.each do |method_name, commands|
          f << "  def #{method_name}\n"
          commands.each do |(_, command)|
            f << "    #{command}\n"
          end
          f << "  end\n"
        end
        f << "end\n\n"
      end
    end

    def translate(name)
      REPLACE_WORDS.each do |old_name, new_name|
        result = name.dup
        if result.match /#{old_name}/
          result.gsub!($&, new_name)
        end
        if result.match /#{pluralize(old_name)}/
          result.gsub!($&, pluralize(new_name))
        end
        if result.match /#{camelize(old_name)}/
          result.gsub!($&, camelize(new_name))
        end
        if result.match /#{camelize(pluralize(old_name))}/
          result.gsub!($&, camelize(pluralize(new_name)))
        end
        return result if result != name
      end
      nil
    end

    def push(*args)
      migration_commands << args
    end

    def migration_filepath
      MIGRATION_DIRPATH.join("#{Time.now.utc.strftime("%Y%m%d%H%M%S")}_rename_via_script.rb")
    end
  end

  class FactoryFilesRenameProvider
    attr_accessor :verbose, :dry_run

    DIR = Pathname.new(File.join('test', 'factories'))

    def initialize(verbose: false, dry_run: true)
      self.verbose = verbose
      self.dry_run = dry_run
    end

    def run
      files_list.each do |filename|
        rename_file(filename)
      end
    end

    def files_list
      Dir.entries(DIR).select { |e| !%w(. ..).include?(e) }
    end

    def rename_file(filename)
      puts "#{DIR.join(filename)} --> #{DIR.join(new_name(filename))}" if verbose
      FileUtils.mv(DIR.join(filename), DIR.join(new_name(filename))) unless dry_run
    end

    def new_name(filename)
      parts = filename.split('.')
      basename = "#{parts.first}_factory"
      [basename, *parts[1..-1]].join('.')
    end
  end
end

Super::MigrationProvider.new(verbose: false, dry_run: false).run
Super::RenameRefactorProvider.new(verbose: true, dry_run: false).run
Super::FactoryFilesRenameProvider.new(verbose: false, dry_run: false).run
