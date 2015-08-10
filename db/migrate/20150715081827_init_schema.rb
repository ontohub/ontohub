class InitSchema < ActiveRecord::Migration
  def down
    raise "Can not revert initial migration"
  end

  def up

    create_table "access_tokens", :force => true do |t|
      t.string   "token"
      t.integer  "repository_id", :null => false
      t.datetime "expiration",    :null => false
      t.datetime "created_at",    :null => false
      t.datetime "updated_at",    :null => false
    end

    add_index "access_tokens", ["token"], :name => "index_access_tokens_on_token"

    create_table "actions", :force => true do |t|
      t.integer  "initial_eta"
      t.integer  "resource_id"
      t.string   "resource_type"
      t.datetime "action_started_at"
      t.datetime "created_at",        :null => false
      t.datetime "updated_at",        :null => false
    end

    add_index "actions", ["resource_id", "resource_type"], :name => "index_actions_on_resource_id_and_resource_type"

    create_table "alternative_iris", :force => true do |t|
      t.text     "iri"
      t.integer  "ontology_id", :null => false
      t.datetime "created_at",  :null => false
      t.datetime "updated_at",  :null => false
    end

    add_index "alternative_iris", ["ontology_id", "iri"], :name => "index_alternative_iris_on_ontology_id_and_iri", :unique => true

    create_table "api_keys", :force => true do |t|
      t.text     "key"
      t.integer  "user_id"
      t.string   "state"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    add_index "api_keys", ["key"], :name => "index_api_keys_on_key", :unique => true
    add_index "api_keys", ["user_id", "state"], :name => "index_api_keys_on_user_id_and_state"
    add_index "api_keys", ["user_id"], :name => "index_api_keys_on_user_id"

    create_table "axiom_selections", :force => true do |t|
      t.integer "as_axiom_selection_id"
      t.string  "as_axiom_selection_type"
    end

    create_table "axioms_axiom_selections", :id => false, :force => true do |t|
      t.integer "sentence_id"
      t.integer "axiom_selection_id"
    end

    add_index "axioms_axiom_selections", ["axiom_selection_id"], :name => "index_axioms_on_axiom_selection_id"
    add_index "axioms_axiom_selections", ["sentence_id", "axiom_selection_id"], :name => "index_axioms_axiom_selection_unique", :unique => true
    add_index "axioms_axiom_selections", ["sentence_id"], :name => "index_axioms_axiom_selections_on_sentence_id"

    create_table "basic_proofs", :force => true do |t|
      t.string   "prover"
      t.text     "proof"
      t.integer  "logic_mapping_id", :null => false
      t.integer  "sentence_id",      :null => false
      t.datetime "created_at",       :null => false
      t.datetime "updated_at",       :null => false
    end

    add_index "basic_proofs", ["logic_mapping_id"], :name => "index_basic_proofs_on_logic_mapping_id"
    add_index "basic_proofs", ["sentence_id"], :name => "index_basic_proofs_on_sentence_id"

    create_table "c_edges", :force => true do |t|
      t.integer "parent_id", :null => false
      t.integer "child_id",  :null => false
    end

    add_index "c_edges", ["parent_id", "child_id"], :name => "index_c_edges_on_parent_id_and_child_id", :unique => true

    create_table "categories", :force => true do |t|
      t.text     "name",       :null => false
      t.string   "ordinal"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    create_table "categories_ontologies", :force => true do |t|
      t.integer "ontology_id", :null => false
      t.integer "category_id", :null => false
    end

    add_index "categories_ontologies", ["category_id", "ontology_id"], :name => "index_c_vertices_ontologies_on_c_vertex_id_and_ontology_id", :unique => true
    add_index "categories_ontologies", ["ontology_id", "category_id"], :name => "index_c_vertices_ontologies_on_ontology_id_and_c_vertex_id"

    create_table "code_references", :force => true do |t|
      t.integer  "begin_line"
      t.integer  "end_line"
      t.integer  "begin_column"
      t.integer  "end_column"
      t.integer  "referencee_id"
      t.string   "referencee_type"
      t.datetime "created_at",      :null => false
      t.datetime "updated_at",      :null => false
    end

    create_table "comments", :force => true do |t|
      t.integer  "commentable_id",   :null => false
      t.string   "commentable_type", :null => false
      t.integer  "user_id",          :null => false
      t.text     "text",             :null => false
      t.datetime "created_at",       :null => false
      t.datetime "updated_at",       :null => false
    end

    add_index "comments", ["commentable_id", "commentable_type", "id"], :name => "index_comments_on_commentable_and_id"
    add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

    create_table "commits", :force => true do |t|
      t.string   "commit_oid",    :limit => 40, :null => false
      t.text     "committer"
      t.text     "author"
      t.datetime "author_date"
      t.datetime "commit_date"
      t.integer  "repository_id",               :null => false
      t.datetime "created_at",                  :null => false
      t.datetime "updated_at",                  :null => false
    end

    add_index "commits", ["author_date"], :name => "index_commits_on_author_date"
    add_index "commits", ["commit_date"], :name => "index_commits_on_commit_date"
    add_index "commits", ["commit_oid"], :name => "index_commits_on_commit_oid"
    add_index "commits", ["repository_id", "commit_oid"], :name => "index_commits_on_repository_id_and_commit_oid", :unique => true
    add_index "commits", ["repository_id", "id"], :name => "index_commits_on_repository_id_and_id", :unique => true

    create_table "e_edges", :force => true do |t|
      t.integer  "parent_id"
      t.integer  "child_id"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    add_index "e_edges", ["child_id"], :name => "index_e_edges_on_child_id"
    add_index "e_edges", ["parent_id"], :name => "index_e_edges_on_parent_id"

    create_table "file_extension_mime_type_mappings", :force => true do |t|
      t.string   "file_extension", :null => false
      t.string   "mime_type",      :null => false
      t.datetime "created_at",     :null => false
      t.datetime "updated_at",     :null => false
    end

    add_index "file_extension_mime_type_mappings", ["mime_type"], :name => "index_file_extension_mime_type_mappings_on_mime_type"

    create_table "formality_levels", :force => true do |t|
      t.text     "name"
      t.text     "description"
      t.datetime "created_at",  :null => false
      t.datetime "updated_at",  :null => false
    end

    add_index "formality_levels", ["name"], :name => "index_formality_levels_on_name", :unique => true

    create_table "generated_axioms", :force => true do |t|
      t.string  "name",             :null => false
      t.integer "proof_attempt_id", :null => false
    end

    add_index "generated_axioms", ["name"], :name => "index_generated_axioms_on_name"

    create_table "goals_proof_attempt_configurations", :id => false, :force => true do |t|
      t.integer "sentence_id"
      t.integer "proof_attempt_configuration_id"
    end

    add_index "goals_proof_attempt_configurations", ["proof_attempt_configuration_id"], :name => "index_goals_pacs_on_proof_attempt_configuration_id"
    add_index "goals_proof_attempt_configurations", ["sentence_id"], :name => "index_goals_proof_attempt_configurations_on_sentence_id"

    create_table "hets_instances", :force => true do |t|
      t.string   "name"
      t.text     "uri",                           :null => false
      t.text     "version"
      t.boolean  "up",         :default => false, :null => false
      t.datetime "created_at",                    :null => false
      t.datetime "updated_at",                    :null => false
    end

    create_table "keys", :force => true do |t|
      t.integer  "user_id",                   :null => false
      t.text     "key",                       :null => false
      t.text     "name",                      :null => false
      t.string   "fingerprint", :limit => 32, :null => false
      t.datetime "created_at",                :null => false
      t.datetime "updated_at",                :null => false
    end

    add_index "keys", ["fingerprint"], :name => "index_keys_on_fingerprint", :unique => true
    add_index "keys", ["user_id"], :name => "index_keys_on_user_id"

    create_table "language_adjoints", :force => true do |t|
      t.integer  "translation_id",                :null => false
      t.integer  "projection_id",                 :null => false
      t.text     "iri"
      t.string   "kind"
      t.datetime "created_at",                    :null => false
      t.datetime "updated_at",                    :null => false
      t.integer  "user_id",        :default => 1, :null => false
    end

    add_index "language_adjoints", ["projection_id"], :name => "index_language_adjoints_on_projection_id"
    add_index "language_adjoints", ["translation_id"], :name => "index_language_adjoints_on_translation_id"

    create_table "language_mappings", :force => true do |t|
      t.integer  "source_id",                             :null => false
      t.integer  "target_id",                             :null => false
      t.text     "iri"
      t.string   "kind"
      t.string   "standardization_status"
      t.string   "defined_by"
      t.datetime "created_at",                            :null => false
      t.datetime "updated_at",                            :null => false
      t.integer  "user_id",                :default => 1, :null => false
    end

    add_index "language_mappings", ["source_id"], :name => "index_language_mappings_on_source_id"
    add_index "language_mappings", ["target_id"], :name => "index_language_mappings_on_target_id"

    create_table "languages", :force => true do |t|
      t.text     "name",                                  :null => false
      t.text     "iri",                                   :null => false
      t.text     "description"
      t.string   "standardization_status"
      t.string   "defined_by"
      t.datetime "created_at",                            :null => false
      t.datetime "updated_at",                            :null => false
      t.integer  "user_id",                :default => 1, :null => false
    end

    add_index "languages", ["iri"], :name => "index_languages_on_iri", :unique => true
    add_index "languages", ["name"], :name => "index_languages_on_name", :unique => true

    create_table "license_models", :force => true do |t|
      t.text     "name"
      t.text     "description"
      t.text     "url"
      t.datetime "created_at",  :null => false
      t.datetime "updated_at",  :null => false
    end

    add_index "license_models", ["name"], :name => "index_license_models_on_name", :unique => true

    create_table "license_models_ontologies", :id => false, :force => true do |t|
      t.integer "license_model_id"
      t.integer "ontology_id"
    end

    create_table "logic_adjoints", :force => true do |t|
      t.integer  "translation_id",                :null => false
      t.integer  "projection_id",                 :null => false
      t.text     "iri"
      t.string   "kind"
      t.datetime "created_at",                    :null => false
      t.datetime "updated_at",                    :null => false
      t.integer  "user_id",        :default => 1, :null => false
    end

    add_index "logic_adjoints", ["projection_id"], :name => "index_logic_adjoints_on_projection_id"
    add_index "logic_adjoints", ["translation_id"], :name => "index_logic_adjoints_on_translation_id"

    create_table "logic_mappings", :force => true do |t|
      t.integer  "source_id",                                       :null => false
      t.integer  "target_id",                                       :null => false
      t.text     "iri"
      t.string   "kind"
      t.string   "standardization_status"
      t.string   "defined_by"
      t.boolean  "default"
      t.boolean  "projection"
      t.string   "faithfulness"
      t.string   "theoroidalness",         :default => "unknown",   :null => false
      t.datetime "created_at",                                      :null => false
      t.datetime "updated_at",                                      :null => false
      t.integer  "user_id",                :default => 1,           :null => false
      t.string   "exactness",              :default => "not_exact", :null => false
      t.string   "slug"
    end

    add_index "logic_mappings", ["source_id"], :name => "index_logic_mappings_on_source_id"
    add_index "logic_mappings", ["target_id"], :name => "index_logic_mappings_on_target_id"

    create_table "logics", :force => true do |t|
      t.text     "name",                                  :null => false
      t.text     "iri",                                   :null => false
      t.text     "description"
      t.string   "standardization_status"
      t.string   "defined_by"
      t.datetime "created_at",                            :null => false
      t.datetime "updated_at",                            :null => false
      t.integer  "user_id"
      t.integer  "ontologies_count",       :default => 0
      t.string   "slug"
    end

    add_index "logics", ["name"], :name => "index_logics_on_name", :unique => true

    create_table "manual_axiom_selections", :force => true do |t|
    end

    create_table "mapping_versions", :force => true do |t|
      t.integer  "mapping_id",                               :null => false
      t.integer  "source_id"
      t.integer  "target_id"
      t.integer  "aux_mapping_id"
      t.integer  "version_number"
      t.boolean  "current"
      t.boolean  "proof_status",         :default => false
      t.string   "required_cons_status", :default => "none"
      t.string   "proven_cons_status",   :default => "none"
      t.datetime "created_at",                               :null => false
      t.datetime "updated_at",                               :null => false
    end

    add_index "mapping_versions", ["mapping_id"], :name => "index_mapping_versions_on_mapping_id"
    add_index "mapping_versions", ["source_id"], :name => "index_mapping_versions_on_source_id"
    add_index "mapping_versions", ["target_id"], :name => "index_mapping_versions_on_target_id"

    create_table "mappings", :force => true do |t|
      t.text     "iri",                                   :null => false
      t.integer  "ontology_id"
      t.integer  "source_id",                             :null => false
      t.integer  "target_id",                             :null => false
      t.integer  "logic_mapping_id"
      t.string   "kind"
      t.boolean  "theorem",            :default => false
      t.boolean  "proven",             :default => false
      t.boolean  "local",              :default => false
      t.boolean  "inclusion",          :default => true
      t.integer  "parent_id"
      t.datetime "created_at",                            :null => false
      t.datetime "updated_at",                            :null => false
      t.text     "name"
      t.integer  "mapping_version_id"
      t.text     "locid"
    end

    add_index "mappings", ["mapping_version_id"], :name => "index_mappings_on_mapping_version_id"
    add_index "mappings", ["ontology_id"], :name => "index_mappings_on_ontology_id"
    add_index "mappings", ["source_id"], :name => "index_mappings_on_source_id"
    add_index "mappings", ["target_id"], :name => "index_mappings_on_target_id"

    create_table "metadata", :force => true do |t|
      t.integer  "metadatable_id"
      t.string   "metadatable_type"
      t.integer  "user_id"
      t.text     "key"
      t.text     "value"
      t.datetime "created_at",       :null => false
      t.datetime "updated_at",       :null => false
    end

    add_index "metadata", ["metadatable_id", "metadatable_type"], :name => "index_metadata_on_metadatable_id_and_metadatable_type"
    add_index "metadata", ["user_id"], :name => "index_metadata_on_user_id"

    create_table "ontologies", :force => true do |t|
      t.string   "type",                :limit => 50,   :default => "SingleOntology", :null => false
      t.integer  "parent_id"
      t.integer  "language_id"
      t.integer  "logic_id"
      t.integer  "ontology_version_id"
      t.string   "state",                               :default => "pending",        :null => false
      t.text     "name"
      t.text     "description"
      t.boolean  "auxiliary",                           :default => false
      t.integer  "symbols_count",                       :default => 0,                :null => false
      t.integer  "sentences_count",                     :default => 0,                :null => false
      t.integer  "versions_count",                      :default => 0,                :null => false
      t.integer  "metadata_count",                      :default => 0,                :null => false
      t.integer  "comments_count",                      :default => 0,                :null => false
      t.datetime "created_at",                                                        :null => false
      t.datetime "updated_at",                                                        :null => false
      t.integer  "repository_id",                                                     :null => false
      t.integer  "ontology_type_id"
      t.string   "acronym"
      t.text     "documentation"
      t.integer  "tool_id"
      t.integer  "license_model_id"
      t.integer  "formality_level_id"
      t.string   "basepath",            :limit => 4096
      t.string   "file_extension",      :limit => 20
      t.boolean  "present",                             :default => false
      t.boolean  "has_file",                            :default => true,             :null => false
      t.integer  "theorems_count",                      :default => 0,                :null => false
      t.text     "locid"
      t.integer  "axioms_count",                        :default => 0,                :null => false
    end

    add_index "ontologies", ["formality_level_id"], :name => "index_ontologies_on_formality_level_id"
    add_index "ontologies", ["language_id"], :name => "index_ontologies_on_language_id"
    add_index "ontologies", ["license_model_id"], :name => "index_ontologies_on_license_model_id"
    add_index "ontologies", ["logic_id"], :name => "index_ontologies_on_logic_id"
    add_index "ontologies", ["name"], :name => "index_ontologies_on_name"
    add_index "ontologies", ["ontology_type_id"], :name => "index_ontologies_on_ontology_type_id"
    add_index "ontologies", ["repository_id", "basepath"], :name => "index_ontologies_on_repository_id_and_basepath"
    add_index "ontologies", ["repository_id", "id"], :name => "index_ontologies_on_repository_id_and_id", :unique => true
    add_index "ontologies", ["state"], :name => "index_ontologies_on_state"
    add_index "ontologies", ["tool_id"], :name => "index_ontologies_on_tool_id"
    add_index "ontologies", ["type"], :name => "index_ontologies_on_type"

    create_table "ontologies_projects", :id => false, :force => true do |t|
      t.integer "ontology_id"
      t.integer "project_id"
    end

    create_table "ontologies_tasks", :id => false, :force => true do |t|
      t.integer "ontology_id", :null => false
      t.integer "task_id",     :null => false
    end

    add_index "ontologies_tasks", ["ontology_id", "task_id"], :name => "index_ontologies_tasks_on_ontology_id_and_task_id", :unique => true

    create_table "ontology_file_extensions", :id => false, :force => true do |t|
      t.string  "extension",   :null => false
      t.boolean "distributed", :null => false
    end

    create_table "ontology_types", :force => true do |t|
      t.text     "name",          :null => false
      t.text     "description",   :null => false
      t.text     "documentation", :null => false
      t.datetime "created_at",    :null => false
      t.datetime "updated_at",    :null => false
    end

    add_index "ontology_types", ["name"], :name => "index_ontology_types_on_name", :unique => true

    create_table "ontology_versions", :force => true do |t|
      t.integer  "user_id"
      t.integer  "ontology_id",                                              :null => false
      t.integer  "previous_version_id"
      t.string   "state",                             :default => "pending"
      t.text     "last_error"
      t.string   "checksum"
      t.integer  "number",                                                   :null => false
      t.datetime "created_at",                                               :null => false
      t.datetime "updated_at",                                               :null => false
      t.string   "commit_oid",          :limit => 40
      t.datetime "state_updated_at"
      t.string   "basepath"
      t.string   "file_extension",      :limit => 20
      t.integer  "parent_id"
      t.integer  "commit_id"
    end

    add_index "ontology_versions", ["checksum"], :name => "index_ontology_versions_on_checksum"
    add_index "ontology_versions", ["commit_oid"], :name => "index_ontology_versions_on_commit_oid"
    add_index "ontology_versions", ["ontology_id", "number"], :name => "index_ontology_versions_on_ontology_id_and_number"
    add_index "ontology_versions", ["previous_version_id"], :name => "index_ontology_versions_on_previous_version_id"
    add_index "ontology_versions", ["user_id"], :name => "index_ontology_versions_on_user_id"

    create_table "ontology_versions_provers", :id => false, :force => true do |t|
      t.integer "ontology_version_id", :null => false
      t.integer "prover_id",           :null => false
    end

    create_table "oops_requests", :force => true do |t|
      t.integer  "ontology_version_id",                                      :null => false
      t.string   "state",               :limit => 50, :default => "pending", :null => false
      t.text     "last_error"
      t.datetime "created_at",                                               :null => false
      t.datetime "updated_at",                                               :null => false
      t.datetime "state_updated_at"
    end

    add_index "oops_requests", ["ontology_version_id"], :name => "index_oops_requests_on_ontology_version_id"

    create_table "oops_responses", :force => true do |t|
      t.integer  "oops_request_id", :null => false
      t.integer  "code",            :null => false
      t.text     "name",            :null => false
      t.text     "description"
      t.string   "element_type",    :null => false
      t.datetime "created_at",      :null => false
      t.datetime "updated_at",      :null => false
    end

    add_index "oops_responses", ["oops_request_id"], :name => "index_oops_responses_on_oops_request_id"

    create_table "oops_responses_symbols", :id => false, :force => true do |t|
      t.integer "oops_response_id", :null => false
      t.integer "symbol_id",        :null => false
    end

    add_index "oops_responses_symbols", ["oops_response_id", "symbol_id"], :name => "index_oops_responses_symbols_on_oops_response_id_and_symbol_id", :unique => true

    create_table "permissions", :force => true do |t|
      t.integer  "subject_id",                         :null => false
      t.string   "subject_type",                       :null => false
      t.integer  "item_id",                            :null => false
      t.string   "item_type",                          :null => false
      t.integer  "creator_id"
      t.string   "role",         :default => "editor", :null => false
      t.datetime "created_at",                         :null => false
      t.datetime "updated_at",                         :null => false
    end

    add_index "permissions", ["creator_id"], :name => "index_permissions_on_creator_id"
    add_index "permissions", ["item_id", "item_type", "subject_id", "subject_type"], :name => "index_permissions_on_item_and_subject", :unique => true
    add_index "permissions", ["subject_id", "subject_type"], :name => "index_permissions_on_subject_id_and_subject_type"

    create_table "projects", :force => true do |t|
      t.text     "name",        :null => false
      t.text     "institution", :null => false
      t.text     "homepage",    :null => false
      t.text     "description", :null => false
      t.text     "contact",     :null => false
      t.datetime "created_at",  :null => false
      t.datetime "updated_at",  :null => false
    end

    add_index "projects", ["name"], :name => "index_projects_on_name", :unique => true

    create_table "proof_attempt_configurations", :force => true do |t|
      t.integer  "timeout"
      t.integer  "prover_id"
      t.integer  "logic_mapping_id"
      t.datetime "created_at",         :null => false
      t.datetime "updated_at",         :null => false
      t.integer  "axiom_selection_id", :null => false
    end

    create_table "proof_attempts", :force => true do |t|
      t.string   "proof_status_id"
      t.integer  "time_taken"
      t.integer  "sentence_id",                                           :null => false
      t.datetime "created_at",                                            :null => false
      t.datetime "updated_at",                                            :null => false
      t.integer  "number",                         :default => 0,         :null => false
      t.integer  "prover_id"
      t.string   "state",                          :default => "pending", :null => false
      t.datetime "state_updated_at"
      t.text     "last_error"
      t.integer  "proof_attempt_configuration_id"
      t.text     "locid"
    end

    create_table "proof_statuses", :id => false, :force => true do |t|
      t.string  "identifier"
      t.string  "name"
      t.string  "label",       :default => "primary", :null => false
      t.text    "description"
      t.boolean "solved"
      t.text    "locid"
    end

    add_index "proof_statuses", ["name"], :name => "index_proof_statuses_on_name", :unique => true

    create_table "prover_outputs", :force => true do |t|
      t.integer  "proof_attempt_id", :null => false
      t.text     "content"
      t.text     "locid"
      t.datetime "created_at",       :null => false
      t.datetime "updated_at",       :null => false
    end

    create_table "provers", :force => true do |t|
      t.string   "name",         :null => false
      t.datetime "created_at",   :null => false
      t.datetime "updated_at",   :null => false
      t.string   "display_name", :null => false
    end

    add_index "provers", ["name"], :name => "index_provers_on_name", :unique => true

    create_table "repositories", :force => true do |t|
      t.string   "path",             :limit => 4096,                         :null => false
      t.text     "name",                                                     :null => false
      t.text     "description"
      t.datetime "created_at",                                               :null => false
      t.datetime "updated_at",                                               :null => false
      t.string   "source_type",      :limit => 5
      t.text     "source_address"
      t.string   "state",            :limit => 30,   :default => "done",     :null => false
      t.text     "last_error"
      t.datetime "imported_at"
      t.string   "access",                           :default => "public_r", :null => false
      t.datetime "state_updated_at"
      t.boolean  "is_destroying",                    :default => false,      :null => false
      t.string   "remote_type"
      t.string   "destroy_job_id"
      t.datetime "destroy_job_at"
    end

    add_index "repositories", ["path"], :name => "index_repositories_on_path", :unique => true

    create_table "resources", :force => true do |t|
      t.integer  "resourcable_id",   :null => false
      t.string   "resourcable_type", :null => false
      t.string   "kind"
      t.text     "uri"
      t.datetime "created_at",       :null => false
      t.datetime "updated_at",       :null => false
    end

    add_index "resources", ["resourcable_id"], :name => "index_resources_on_resourcable_id"

    create_table "reviews", :force => true do |t|
      t.integer  "ontology_id"
      t.text     "text"
      t.datetime "created_at",  :null => false
      t.datetime "updated_at",  :null => false
    end

    add_index "reviews", ["ontology_id"], :name => "index_reviews_on_ontology_id"

    create_table "sentences", :force => true do |t|
      t.integer  "ontology_id",                         :null => false
      t.text     "name",                                :null => false
      t.text     "text",                                :null => false
      t.string   "range"
      t.integer  "comments_count",   :default => 0,     :null => false
      t.datetime "created_at",                          :null => false
      t.datetime "updated_at",                          :null => false
      t.text     "display_text"
      t.boolean  "imported",         :default => false, :null => false
      t.string   "type"
      t.string   "proof_status_id"
      t.text     "locid"
      t.string   "state"
      t.datetime "state_updated_at"
      t.text     "last_error"
    end

    add_index "sentences", ["ontology_id", "id"], :name => "index_sentences_on_ontology_id_and_id", :unique => true
    add_index "sentences", ["ontology_id", "name"], :name => "index_sentences_on_ontology_id_and_name", :unique => true

    create_table "sentences_symbols", :id => false, :force => true do |t|
      t.integer "sentence_id", :null => false
      t.integer "symbol_id",   :null => false
      t.integer "ontology_id", :null => false
    end

    add_index "sentences_symbols", ["sentence_id", "symbol_id"], :name => "index_sentences_symbols_on_sentence_id_and_symbol_id", :unique => true
    add_index "sentences_symbols", ["symbol_id", "sentence_id"], :name => "index_sentences_symbols_on_symbol_id_and_sentence_id"

    create_table "serializations", :force => true do |t|
      t.text     "name"
      t.string   "extension"
      t.string   "mimetype"
      t.integer  "language_id", :null => false
      t.datetime "created_at",  :null => false
      t.datetime "updated_at",  :null => false
    end

    add_index "serializations", ["language_id"], :name => "index_serializations_on_language_id"

    create_table "structured_proof_parts", :force => true do |t|
      t.integer  "structured_proof_id", :null => false
      t.integer  "sentence_id",         :null => false
      t.integer  "mapping_version_id",  :null => false
      t.datetime "created_at",          :null => false
      t.datetime "updated_at",          :null => false
    end

    add_index "structured_proof_parts", ["mapping_version_id"], :name => "index_structured_proof_parts_on_mapping_version_id"
    add_index "structured_proof_parts", ["sentence_id"], :name => "index_structured_proof_parts_on_sentence_id"
    add_index "structured_proof_parts", ["structured_proof_id"], :name => "index_structured_proof_parts_on_structured_proof_id"

    create_table "structured_proofs", :force => true do |t|
      t.string   "rule"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    create_table "supports", :force => true do |t|
      t.integer  "language_id", :null => false
      t.integer  "logic_id",    :null => false
      t.boolean  "exact"
      t.datetime "created_at",  :null => false
      t.datetime "updated_at",  :null => false
    end

    add_index "supports", ["language_id", "logic_id"], :name => "index_supports_on_language_id_and_logic_id", :unique => true
    add_index "supports", ["language_id"], :name => "index_supports_on_language_id"
    add_index "supports", ["logic_id"], :name => "index_supports_on_logic_id"

    create_table "symbol_groups", :force => true do |t|
      t.integer  "ontology_id"
      t.text     "name",        :null => false
      t.datetime "created_at",  :null => false
      t.datetime "updated_at",  :null => false
    end

    add_index "symbol_groups", ["ontology_id", "id"], :name => "index_symbol_groups_on_ontology_id_and_id", :unique => true

    create_table "symbol_mappings", :force => true do |t|
      t.integer  "source_id",  :null => false
      t.integer  "target_id",  :null => false
      t.integer  "confidence"
      t.string   "kind"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
      t.integer  "mapping_id", :null => false
    end

    add_index "symbol_mappings", ["source_id"], :name => "index_symbol_mappings_on_source_id"
    add_index "symbol_mappings", ["target_id"], :name => "index_symbol_mappings_on_target_id"

    create_table "symbols", :force => true do |t|
      t.integer  "ontology_id",                    :null => false
      t.string   "kind"
      t.text     "text",                           :null => false
      t.text     "name",                           :null => false
      t.text     "iri"
      t.string   "range"
      t.integer  "comments_count",  :default => 0, :null => false
      t.datetime "created_at",                     :null => false
      t.datetime "updated_at",                     :null => false
      t.text     "display_name"
      t.text     "label"
      t.text     "comment"
      t.integer  "symbol_group_id"
      t.text     "locid"
    end

    add_index "symbols", ["display_name"], :name => "index_symbols_on_display_name"
    add_index "symbols", ["name"], :name => "index_symbols_on_name"
    add_index "symbols", ["ontology_id", "id"], :name => "index_symbols_on_ontology_id_and_id", :unique => true
    add_index "symbols", ["ontology_id", "kind"], :name => "index_symbols_on_ontology_id_and_kind"
    add_index "symbols", ["ontology_id", "text"], :name => "index_symbols_on_ontology_id_and_text", :unique => true
    add_index "symbols", ["text"], :name => "index_symbols_on_text"

    create_table "tactic_script_extra_options", :force => true do |t|
      t.integer  "tactic_script_id", :null => false
      t.text     "option",           :null => false
      t.datetime "created_at",       :null => false
      t.datetime "updated_at",       :null => false
    end

    create_table "tactic_scripts", :force => true do |t|
      t.integer  "proof_attempt_id", :null => false
      t.integer  "time_limit"
      t.datetime "created_at",       :null => false
      t.datetime "updated_at",       :null => false
    end

    create_table "tasks", :force => true do |t|
      t.text     "name",        :null => false
      t.text     "description"
      t.datetime "created_at",  :null => false
      t.datetime "updated_at",  :null => false
    end

    add_index "tasks", ["name"], :name => "index_tasks_on_name", :unique => true

    create_table "team_users", :force => true do |t|
      t.integer "team_id",                       :null => false
      t.integer "user_id",                       :null => false
      t.integer "creator_id"
      t.boolean "admin",      :default => false, :null => false
    end

    add_index "team_users", ["creator_id"], :name => "index_team_users_on_creator_id"
    add_index "team_users", ["team_id", "user_id"], :name => "index_team_users_on_team_id_and_user_id", :unique => true
    add_index "team_users", ["user_id"], :name => "index_team_users_on_user_id"

    create_table "teams", :force => true do |t|
      t.text "name", :null => false
    end

    add_index "teams", ["name"], :name => "index_teams_on_name", :unique => true

    create_table "tools", :force => true do |t|
      t.text     "name",        :null => false
      t.text     "description"
      t.text     "url"
      t.datetime "created_at",  :null => false
      t.datetime "updated_at",  :null => false
    end

    add_index "tools", ["name"], :name => "index_tools_on_name", :unique => true

    create_table "translated_sentences", :force => true do |t|
      t.text     "translated_text",   :null => false
      t.integer  "audience_id"
      t.integer  "ontology_id"
      t.integer  "sentence_id"
      t.integer  "symbol_mapping_id"
      t.datetime "created_at",        :null => false
      t.datetime "updated_at",        :null => false
    end

    add_index "translated_sentences", ["audience_id"], :name => "index_translated_sentences_on_audience_id"
    add_index "translated_sentences", ["ontology_id"], :name => "index_translated_sentences_on_ontology_id"

    create_table "url_maps", :force => true do |t|
      t.text     "source",        :null => false
      t.text     "target",        :null => false
      t.integer  "repository_id", :null => false
      t.datetime "created_at",    :null => false
      t.datetime "updated_at",    :null => false
    end

    add_index "url_maps", ["repository_id", "source"], :name => "index_url_maps_on_repository_id_and_source", :unique => true

    create_table "used_axioms_proof_attempts", :id => false, :force => true do |t|
      t.integer "sentence_id"
      t.integer "proof_attempt_id"
    end

    add_index "used_axioms_proof_attempts", ["proof_attempt_id"], :name => "index_used_axioms_proof_attempts_on_proof_attempt_id"
    add_index "used_axioms_proof_attempts", ["sentence_id"], :name => "index_used_axioms_proof_attempts_on_sentence_id"

    create_table "used_sentences", :force => true do |t|
      t.integer  "basic_proof_id", :null => false
      t.integer  "sentence_id",    :null => false
      t.datetime "created_at",     :null => false
      t.datetime "updated_at",     :null => false
    end

    add_index "used_sentences", ["basic_proof_id"], :name => "index_used_sentences_on_basic_proof_id"
    add_index "used_sentences", ["sentence_id"], :name => "index_used_sentences_on_sentence_id"

    create_table "users", :force => true do |t|
      t.string   "email"
      t.string   "encrypted_password"
      t.string   "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer  "sign_in_count",          :default => 0
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string   "current_sign_in_ip"
      t.string   "last_sign_in_ip"
      t.string   "confirmation_token"
      t.datetime "confirmed_at"
      t.datetime "confirmation_sent_at"
      t.string   "unconfirmed_email"
      t.integer  "failed_attempts",        :default => 0
      t.string   "unlock_token"
      t.datetime "locked_at"
      t.text     "name"
      t.boolean  "admin",                  :default => false, :null => false
      t.datetime "created_at",                                :null => false
      t.datetime "updated_at",                                :null => false
      t.datetime "deleted_at"
    end

    add_index "users", ["email"], :name => "index_users_on_email", :unique => true
    add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
    add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

    add_foreign_key "access_tokens", "repositories", name: "access_tokens_repository_id_fk"

    add_foreign_key "alternative_iris", "ontologies", name: "alternative_iris_ontology_id_fk"

    add_foreign_key "basic_proofs", "logic_mappings", name: "basic_proofs_logic_mapping_id_fk", dependent: :delete
    add_foreign_key "basic_proofs", "sentences", name: "basic_proofs_sentence_id_fk", dependent: :delete

    add_foreign_key "categories_ontologies", "categories", name: "c_vertices_ontologies_c_vertex_id_fk", dependent: :delete
    add_foreign_key "categories_ontologies", "ontologies", name: "c_vertices_ontologies_ontology_id_fk", dependent: :delete

    add_foreign_key "comments", "users", name: "comments_user_id_fk"

    add_foreign_key "keys", "users", name: "keys_user_id_fk", dependent: :delete

    add_foreign_key "language_adjoints", "language_mappings", name: "language_adjoints_projection_id_fk", column: "projection_id", dependent: :delete
    add_foreign_key "language_adjoints", "language_mappings", name: "language_adjoints_translation_id_fk", column: "translation_id", dependent: :delete
    add_foreign_key "language_adjoints", "users", name: "language_adjoints_user_id_fk"

    add_foreign_key "language_mappings", "languages", name: "language_mappings_source_id_fk", column: "source_id", dependent: :delete
    add_foreign_key "language_mappings", "languages", name: "language_mappings_target_id_fk", column: "target_id", dependent: :delete
    add_foreign_key "language_mappings", "users", name: "language_mappings_user_id_fk"

    add_foreign_key "languages", "users", name: "languages_user_id_fk"

    add_foreign_key "logic_adjoints", "logic_mappings", name: "logic_adjoints_projection_id_fk", column: "projection_id", dependent: :delete
    add_foreign_key "logic_adjoints", "logic_mappings", name: "logic_adjoints_translation_id_fk", column: "translation_id", dependent: :delete
    add_foreign_key "logic_adjoints", "users", name: "logic_adjoints_user_id_fk"

    add_foreign_key "logic_mappings", "logics", name: "logic_mappings_source_id_fk", column: "source_id", dependent: :delete
    add_foreign_key "logic_mappings", "logics", name: "logic_mappings_target_id_fk", column: "target_id", dependent: :delete

    add_foreign_key "logics", "users", name: "logics_user_id_fk"

    add_foreign_key "mapping_versions", "mappings", name: "mapping_versions_mapping_id_fk", dependent: :delete
    add_foreign_key "mapping_versions", "ontology_versions", name: "mapping_versions_source_id_fk", column: "source_id", dependent: :delete
    add_foreign_key "mapping_versions", "ontology_versions", name: "mapping_versions_target_id_fk", column: "target_id", dependent: :delete

    add_foreign_key "mappings", "mappings", name: "mappings_parent_id_fk", column: "parent_id"
    add_foreign_key "mappings", "ontologies", name: "mappings_ontology_id_fk", dependent: :delete
    add_foreign_key "mappings", "ontologies", name: "mappings_source_id_fk", column: "source_id"
    add_foreign_key "mappings", "ontologies", name: "mappings_target_id_fk", column: "target_id"

    add_foreign_key "metadata", "users", name: "metadata_user_id_fk"

    add_foreign_key "ontologies", "formality_levels", name: "ontologies_formality_level_id_fk"
    add_foreign_key "ontologies", "languages", name: "ontologies_language_id_fk"
    add_foreign_key "ontologies", "license_models", name: "ontologies_license_model_id_fk"
    add_foreign_key "ontologies", "logics", name: "ontologies_logic_id_fk"
    add_foreign_key "ontologies", "ontologies", name: "ontologies_parent_id_fk", column: "parent_id"
    add_foreign_key "ontologies", "ontologies", name: "ontologies_parent_id_fkey", column: "parent_id"
    add_foreign_key "ontologies", "ontology_types", name: "ontologies_ontology_type_id_fk"
    add_foreign_key "ontologies", "repositories", name: "ontologies_repository_id_fk"
    add_foreign_key "ontologies", "tools", name: "ontologies_tool_id_fk"

    add_foreign_key "ontologies_tasks", "ontologies", name: "ontologies_tasks_ontology_id_fk"
    add_foreign_key "ontologies_tasks", "tasks", name: "ontologies_tasks_task_id_fk"

    add_foreign_key "ontology_versions", "ontologies", name: "ontology_versions_ontology_id_fk", dependent: :delete
    add_foreign_key "ontology_versions", "ontology_versions", name: "ontology_versions_parent_id_fk", column: "parent_id"
    add_foreign_key "ontology_versions", "ontology_versions", name: "ontology_versions_previous_version_id_fk", column: "previous_version_id"
    add_foreign_key "ontology_versions", "users", name: "ontology_versions_user_id_fk"

    add_foreign_key "oops_requests", "ontology_versions", name: "oops_requests_ontology_version_id_fk", dependent: :delete

    add_foreign_key "oops_responses", "oops_requests", name: "oops_responses_oops_request_id_fk", dependent: :delete

    add_foreign_key "oops_responses_symbols", "oops_responses", name: "oops_responses_symbols_oops_response_id_fk", dependent: :delete
    add_foreign_key "oops_responses_symbols", "symbols", name: "oops_responses_symbols_symbol_id_fk"

    add_foreign_key "permissions", "users", name: "permissions_creator_id_fk", column: "creator_id", dependent: :nullify

    add_foreign_key "sentences", "ontologies", name: "sentences_ontology_id_fk", dependent: :delete

    add_foreign_key "sentences_symbols", "ontologies", name: "sentences_symbols_ontology_id_fk", dependent: :delete
    add_foreign_key "sentences_symbols", "sentences", name: "sentences_symbols_sentence_id_fk", dependent: :delete
    add_foreign_key "sentences_symbols", "symbols", name: "sentences_symbols_symbol_id_fk", dependent: :delete

    add_foreign_key "serializations", "languages", name: "serializations_language_id_fk"

    add_foreign_key "structured_proof_parts", "mapping_versions", name: "structured_proof_parts_mapping_version_id_fk", dependent: :delete
    add_foreign_key "structured_proof_parts", "sentences", name: "structured_proof_parts_sentence_id_fk", dependent: :delete
    add_foreign_key "structured_proof_parts", "structured_proofs", name: "structured_proof_parts_structured_proof_id_fk", dependent: :delete

    add_foreign_key "supports", "languages", name: "supports_language_id_fk"
    add_foreign_key "supports", "logics", name: "supports_logic_id_fk"

    add_foreign_key "symbol_groups", "ontologies", name: "symbol_groups_ontology_id_fk", dependent: :delete

    add_foreign_key "symbol_mappings", "symbols", name: "symbol_mappings_source_id_fk", column: "source_id", dependent: :delete
    add_foreign_key "symbol_mappings", "symbols", name: "symbol_mappings_target_id_fk", column: "target_id", dependent: :delete

    add_foreign_key "symbols", "ontologies", name: "symbols_ontology_id_fk", dependent: :delete

    add_foreign_key "team_users", "teams", name: "team_users_team_id_fk", dependent: :delete
    add_foreign_key "team_users", "users", name: "team_users_creator_id_fk", column: "creator_id", dependent: :nullify
    add_foreign_key "team_users", "users", name: "team_users_user_id_fk", dependent: :delete

    add_foreign_key "url_maps", "repositories", name: "url_maps_repository_id_fk"

    add_foreign_key "used_sentences", "basic_proofs", name: "used_sentences_basic_proof_id_fk", dependent: :delete
    add_foreign_key "used_sentences", "sentences", name: "used_sentences_sentence_id_fk", dependent: :delete

    add_function_fetch_distributed_graph_data
    add_function_fetch_graph_data
    add_check_logic_id
    populate_database_with_ontology_file_extensions
    populate_database_with_file_extension_mime_type_mappings
  end

  def add_function_fetch_distributed_graph_data
    execute <<-SQL
CREATE OR REPLACE FUNCTION fetch_distributed_graph_data(
  distributed_id integer)
  RETURNS SETOF integer AS $$
BEGIN
  RETURN QUERY WITH "graph_core" AS (
    SELECT "mappings"."id",
      "mappings"."target_id",
      "mappings"."source_id"
      FROM "mappings"
      WHERE "mappings"."ontology_id" = distributed_id),
  "graph_data" AS (
    SELECT ("graph_core"."source_id") AS node_id,
      ("graph_core"."id") AS edge_id
       FROM graph_core
    UNION
    SELECT ("graph_core"."target_id") AS node_id,
      ("graph_core"."id") AS edge_id
      FROM graph_core)
  SELECT DISTINCT "graph_data"."node_id"
    FROM "graph_data";
END;
$$ language plpgsql;
    SQL
  end

  def add_function_fetch_graph_data
    $function_declaration = "fetch_graph_data(center_id integer, source_tbl regclass, target_tbl regclass, depth integer)"
    execute <<-SQL
CREATE TYPE graph_data_type AS (
  node_id integer,
  edge_id integer,
  depth integer
);

CREATE OR REPLACE FUNCTION #{$function_declaration}
    RETURNS SETOF graph_data_type AS $$
BEGIN
RETURN QUERY EXECUTE format('
  WITH RECURSIVE graph_data(node_id, edge_id, depth) AS (
      (WITH mergeable AS (
        SELECT (%s."source_id") AS source_id,
          (%s."target_id") AS target_id,
          (%s."id") AS edge_id,
          1 AS depth
        FROM %s
        WHERE (%s."source_id" = %s OR
          %s."target_id" = %s)
        )
        SELECT (source_id) AS node_id, edge_id, depth FROM mergeable
        UNION
        SELECT (target_id) AS node_id, edge_id, depth FROM mergeable
      )
    UNION ALL
      (WITH mergeable AS (
        SELECT (%s."source_id") AS source_id,
          (%s."target_id") AS target_id,
          (%s."id") AS edge_id,
          (graph_data.depth+1) AS depth
        FROM %s
        INNER JOIN graph_data
        ON (%s."source_id" = "graph_data"."node_id" OR
          %s."target_id" = "graph_data"."node_id")
        WHERE graph_data.depth < %s)
      SELECT (source_id) AS node_id, edge_id, depth FROM mergeable
      UNION
      SELECT (target_id) AS node_id, edge_id, depth FROM mergeable
    )
  )
  SELECT DISTINCT * from graph_data;
', source_tbl, source_tbl, source_tbl,
source_tbl, source_tbl, center_id,
source_tbl, center_id,
source_tbl, source_tbl, source_tbl,
source_tbl, source_tbl, source_tbl,
depth);
END;
$$ language plpgsql;
    SQL
  end

  def add_check_logic_id
    execute <<-SQL
ALTER TABLE ontologies
ADD CONSTRAINT logic_id_check CHECK (state != 'done' OR logic_id IS NOT NULL OR type = 'DistributedOntology')
    SQL
  end

  def populate_database_with_ontology_file_extensions
    file_extensions_distributed = %w[casl dol hascasl het]
    file_extensions_single = %w[owl omn obo hs exp maude elf hol isa thy prf omdoc hpf clf clif xml fcstd rdf xmi qvt tptp gen_trm baf]

    file_extensions_distributed.map! { |e| ".#{e}" }
    file_extensions_single.map! { |e| ".#{e}" }

    file_extensions_distributed.each do |ext|
      ActiveRecord::Base.connection.execute(
        "INSERT INTO ontology_file_extensions (extension, distributed) VALUES ('#{ext}', 'true')")
    end
    file_extensions_single.each do |ext|
      ActiveRecord::Base.connection.execute(
        "INSERT INTO ontology_file_extensions (extension, distributed) VALUES ('#{ext}', 'false')")
    end
  end

  def populate_database_with_file_extension_mime_type_mappings
    mappings = [
      %w(.clif text/clif),
      %w(.owl application/owl),
      %w(.owl text/obo),
      %w(.ttl text/turtle),
      %w(.owx application/owl+xml),
      %w(.casl text/casl),
      %w(.dol text/dol),
      %w(.het text/het),
    ]

    mappings.each do |(file_extension, mime_type)|
      FileExtensionMimeTypeMapping.
        where(file_extension: file_extension, mime_type: mime_type).
        first_or_create!
    end
  end
end
