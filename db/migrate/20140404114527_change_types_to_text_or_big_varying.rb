class ChangeTypesToTextOrBigVarying < ActiveRecord::Migration
  def change
    change_table :entities, bulk: true do |t|
      t.change :name, :text
      t.change :display_name, :text
      t.change :label, :text
    end

    change_table :categories, bulk: true do |t|
      t.change :name, :text
    end

    change_table :formality_levels, bulk: true do |t|
      t.change :name, :text
      t.change :description, :text
    end

    change_table :license_models, bulk: true do |t|
      t.change :name, :text
      t.change :description, :text
      t.change :url, :text
    end

    change_table :links, bulk: true do |t|
      t.change :name, :text
    end

    change_table :logics, bulk: true do |t|
      t.change :name, :text
    end

    change_table :keys, bulk: true do |t|
      t.change :name, :text
    end

    change_table :languages, bulk: true do |t|
      t.change :name, :text
    end

    change_table :metadata, bulk: true do |t|
      t.change :key, :text
      t.change :value, :text
    end

    change_table :ontologies, bulk: true do |t|
      t.change :name, :text
      t.change :documentation, :text
      # Account at least for PATH_MAX on most linux systems
      t.change :basepath, :string, limit: 4096
    end

    change_table :ontology_types, bulk: true do |t|
      t.change :name, :text
      t.change :description, :text
      t.change :documentation, :text
    end

    change_table :ontology_versions, bulk: true do |t|
      t.change :source_url, :text
    end

    change_table :oops_responses, bulk: true do |t|
      t.change :name, :text
    end

    change_table :projects, bulk: true do |t|
      t.change :name, :text
      t.change :institution, :text
      t.change :homepage, :text
      t.change :description, :text
      t.change :contact, :text
    end

    change_table :repositories, bulk: true do |t|
      t.change :name, :text
      # Account at least for PATH_MAX on most linux systems
      t.change :path, :string, limit: 4096
      t.change :source_address, :text
    end

    change_table :resources, bulk: true do |t|
      t.change :uri, :text
    end

    change_table :sentences, bulk: true do |t|
      t.change :name, :text
    end

    change_table :serializations, bulk: true do |t|
      t.change :name, :text
    end

    change_table :tasks, bulk: true do |t|
      t.change :name, :text
    end

    change_table :teams, bulk: true do |t|
      t.change :name, :text
    end

    change_table :tools, bulk: true do |t|
      t.change :name, :text
      t.change :description, :text
      t.change :url, :text
    end

    change_table :url_maps, bulk: true do |t|
      t.change :source, :text
      t.change :target, :text
    end

    change_table :users, bulk: true do |t|
      t.change :name, :text
    end
  end
end
