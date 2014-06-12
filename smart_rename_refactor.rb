#!/usr/bin/env ruby

require 'active_support'
require 'fileutils'

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
        "s/#{old_word}/#{new_word}/g",
        "s/#{pluralize(old_word)}/#{pluralize(new_word)}/g",
        "s/#{camelize(old_word)}/#{camelize(new_word)}/g",
        "s/#{camelize(pluralize(old_word))}/#{camelize(pluralize(new_word))}/g",
      ]
      command = "sed -i -e '#{commands.join(';')}' #{file}"
      # puts command if verbose
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

    def sed_variant
      'gsed'
    end

  end
end

Super::RenameRefactorProvider.new(verbose: true, dry_run: true).run
