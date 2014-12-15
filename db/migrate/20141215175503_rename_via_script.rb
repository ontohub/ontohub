class RenameViaScript < ActiveRecord::Migration
  def up
    execute <<-SQL
      DROP FUNCTION fetch_distributed_graph_data(distributed_id integer);
    SQL

    execute <<-SQL
      CREATE OR REPLACE FUNCTION fetch_distributed_graph_data(distributed_id integer)
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

    rename_column 'entities', 'entity_group_id', 'symbol_group_id'
    rename_table 'entities', 'symbols'
    rename_column 'entities_oops_responses', 'entity_id', 'symbol_id'
    rename_table 'entities_oops_responses', 'symbols_oops_responses'
    rename_column 'entities_sentences', 'entity_id', 'symbol_id'
    rename_table 'entities_sentences', 'symbols_sentences'
    rename_table 'entity_groups', 'symbol_groups'
    rename_column 'entity_mappings', 'link_id', 'mapping_id'
    rename_table 'entity_mappings', 'symbol_mappings'
    rename_column 'link_versions', 'link_id', 'mapping_id'
    rename_column 'link_versions', 'aux_link_id', 'aux_mapping_id'
    rename_table 'link_versions', 'mapping_versions'
    rename_column 'links', 'link_version_id', 'mapping_version_id'
    rename_table 'links', 'mappings'
    rename_column 'ontologies', 'entities_count', 'symbols_count'
    rename_column 'structured_proof_parts', 'link_version_id', 'mapping_version_id'
    rename_column 'translated_sentences', 'entity_mapping_id', 'symbol_mapping_id'
    execute "ALTER TABLE ONLY symbols RENAME CONSTRAINT entities_pkey TO symbols_pkey;"
    execute "ALTER TABLE ONLY symbol_groups RENAME CONSTRAINT entity_groups_pkey TO symbol_groups_pkey;"
    execute "ALTER TABLE ONLY symbol_mappings RENAME CONSTRAINT entity_mappings_pkey TO symbol_mappings_pkey;"
    execute "ALTER TABLE ONLY mapping_versions RENAME CONSTRAINT link_versions_pkey TO mapping_versions_pkey;"
    execute "ALTER TABLE ONLY mappings RENAME CONSTRAINT links_pkey TO mappings_pkey;"
    remove_index 'symbols', name: 'index_entities_on_display_name'
    add_index 'symbols', ['display_name'], unique: false, name: 'index_symbols_on_display_name'
    remove_index 'symbols', name: 'index_entities_on_name'
    add_index 'symbols', ['name'], unique: false, name: 'index_symbols_on_name'
    remove_index 'symbols', name: 'index_entities_on_ontology_id_and_id'
    add_index 'symbols', ['ontology_id', 'id'], unique: true, name: 'index_symbols_on_ontology_id_and_id'
    remove_index 'symbols', name: 'index_entities_on_ontology_id_and_kind'
    add_index 'symbols', ['ontology_id', 'kind'], unique: false, name: 'index_symbols_on_ontology_id_and_kind'
    remove_index 'symbols', name: 'index_entities_on_ontology_id_and_text'
    add_index 'symbols', ['ontology_id', 'text'], unique: true, name: 'index_symbols_on_ontology_id_and_text'
    remove_index 'symbols', name: 'index_entities_on_text'
    add_index 'symbols', ['text'], unique: false, name: 'index_symbols_on_text'
    remove_index 'symbols_oops_responses', name: 'index_entities_oops_responses_on_oops_response_id_and_entity_id'
    add_index 'symbols_oops_responses', ['oops_response_id', 'symbol_id'], unique: true, name: 'index_symbols_oops_responses_on_oops_response_id_and_symbol_id'
    remove_index 'symbols_sentences', name: 'index_entities_sentences_on_entity_id_and_sentence_id'
    add_index 'symbols_sentences', ['symbol_id', 'sentence_id'], unique: false, name: 'index_symbols_sentences_on_symbol_id_and_sentence_id'
    remove_index 'symbols_sentences', name: 'index_entities_sentences_on_sentence_id_and_entity_id'
    add_index 'symbols_sentences', ['sentence_id', 'symbol_id'], unique: true, name: 'index_symbols_sentences_on_sentence_id_and_symbol_id'
    remove_index 'symbol_groups', name: 'index_entity_groups_on_ontology_id_and_id'
    add_index 'symbol_groups', ['ontology_id', 'id'], unique: true, name: 'index_symbol_groups_on_ontology_id_and_id'
    remove_index 'symbol_mappings', name: 'index_entity_mappings_on_source_id'
    add_index 'symbol_mappings', ['source_id'], unique: false, name: 'index_symbol_mappings_on_source_id'
    remove_index 'symbol_mappings', name: 'index_entity_mappings_on_target_id'
    add_index 'symbol_mappings', ['target_id'], unique: false, name: 'index_symbol_mappings_on_target_id'
    remove_index 'mapping_versions', name: 'index_link_versions_on_link_id'
    add_index 'mapping_versions', ['mapping_id'], unique: false, name: 'index_mapping_versions_on_mapping_id'
    remove_index 'mapping_versions', name: 'index_link_versions_on_source_id'
    add_index 'mapping_versions', ['source_id'], unique: false, name: 'index_mapping_versions_on_source_id'
    remove_index 'mapping_versions', name: 'index_link_versions_on_target_id'
    add_index 'mapping_versions', ['target_id'], unique: false, name: 'index_mapping_versions_on_target_id'
    remove_index 'mappings', name: 'index_links_on_link_version_id'
    add_index 'mappings', ['mapping_version_id'], unique: false, name: 'index_mappings_on_mapping_version_id'
    remove_index 'mappings', name: 'index_links_on_ontology_id'
    add_index 'mappings', ['ontology_id'], unique: false, name: 'index_mappings_on_ontology_id'
    remove_index 'mappings', name: 'index_links_on_source_id'
    add_index 'mappings', ['source_id'], unique: false, name: 'index_mappings_on_source_id'
    remove_index 'mappings', name: 'index_links_on_target_id'
    add_index 'mappings', ['target_id'], unique: false, name: 'index_mappings_on_target_id'
    remove_index 'structured_proof_parts', name: 'index_structured_proof_parts_on_link_version_id'
    add_index 'structured_proof_parts', ['mapping_version_id'], unique: false, name: 'index_structured_proof_parts_on_mapping_version_id'
    execute "ALTER TABLE ONLY symbols DROP CONSTRAINT entities_ontology_id_fk;"
    execute "ALTER TABLE ONLY symbols ADD CONSTRAINT symbols_ontology_id_fk FOREIGN KEY (ontology_id) REFERENCES ontologies(id) ON DELETE CASCADE;"
    execute "ALTER TABLE ONLY symbols_oops_responses DROP CONSTRAINT entities_oops_responses_entity_id_fk;"
    execute "ALTER TABLE ONLY symbols_oops_responses ADD CONSTRAINT symbols_oops_responses_symbol_id_fk FOREIGN KEY (symbol_id) REFERENCES symbols(id);"
    execute "ALTER TABLE ONLY symbols_oops_responses DROP CONSTRAINT entities_oops_responses_oops_response_id_fk;"
    execute "ALTER TABLE ONLY symbols_oops_responses ADD CONSTRAINT symbols_oops_responses_oops_response_id_fk FOREIGN KEY (oops_response_id) REFERENCES oops_responses(id) ON DELETE CASCADE;"
    execute "ALTER TABLE ONLY symbols_sentences DROP CONSTRAINT entities_sentences_entity_id_fk;"
    execute "ALTER TABLE ONLY symbols_sentences ADD CONSTRAINT symbols_sentences_symbol_id_fk FOREIGN KEY (symbol_id) REFERENCES symbols(id) ON DELETE CASCADE;"
    execute "ALTER TABLE ONLY symbols_sentences DROP CONSTRAINT entities_sentences_ontology_id_fk;"
    execute "ALTER TABLE ONLY symbols_sentences ADD CONSTRAINT symbols_sentences_ontology_id_fk FOREIGN KEY (ontology_id) REFERENCES ontologies(id) ON DELETE CASCADE;"
    execute "ALTER TABLE ONLY symbols_sentences DROP CONSTRAINT entities_sentences_sentence_id_fk;"
    execute "ALTER TABLE ONLY symbols_sentences ADD CONSTRAINT symbols_sentences_sentence_id_fk FOREIGN KEY (sentence_id) REFERENCES sentences(id) ON DELETE CASCADE;"
    execute "ALTER TABLE ONLY symbol_groups DROP CONSTRAINT entity_groups_ontology_id_fk;"
    execute "ALTER TABLE ONLY symbol_groups ADD CONSTRAINT symbol_groups_ontology_id_fk FOREIGN KEY (ontology_id) REFERENCES ontologies(id) ON DELETE CASCADE;"
    execute "ALTER TABLE ONLY symbol_mappings DROP CONSTRAINT entity_mappings_source_id_fk;"
    execute "ALTER TABLE ONLY symbol_mappings ADD CONSTRAINT symbol_mappings_source_id_fk FOREIGN KEY (source_id) REFERENCES symbols(id) ON DELETE CASCADE;"
    execute "ALTER TABLE ONLY symbol_mappings DROP CONSTRAINT entity_mappings_target_id_fk;"
    execute "ALTER TABLE ONLY symbol_mappings ADD CONSTRAINT symbol_mappings_target_id_fk FOREIGN KEY (target_id) REFERENCES symbols(id) ON DELETE CASCADE;"
    execute "ALTER TABLE ONLY mapping_versions DROP CONSTRAINT link_versions_link_id_fk;"
    execute "ALTER TABLE ONLY mapping_versions ADD CONSTRAINT mapping_versions_mapping_id_fk FOREIGN KEY (mapping_id) REFERENCES mappings(id) ON DELETE CASCADE;"
    execute "ALTER TABLE ONLY mapping_versions DROP CONSTRAINT link_versions_source_id_fk;"
    execute "ALTER TABLE ONLY mapping_versions ADD CONSTRAINT mapping_versions_source_id_fk FOREIGN KEY (source_id) REFERENCES ontology_versions(id) ON DELETE CASCADE;"
    execute "ALTER TABLE ONLY mapping_versions DROP CONSTRAINT link_versions_target_id_fk;"
    execute "ALTER TABLE ONLY mapping_versions ADD CONSTRAINT mapping_versions_target_id_fk FOREIGN KEY (target_id) REFERENCES ontology_versions(id) ON DELETE CASCADE;"
    execute "ALTER TABLE ONLY mappings DROP CONSTRAINT links_ontology_id_fk;"
    execute "ALTER TABLE ONLY mappings ADD CONSTRAINT mappings_ontology_id_fk FOREIGN KEY (ontology_id) REFERENCES ontologies(id) ON DELETE CASCADE;"
    execute "ALTER TABLE ONLY mappings DROP CONSTRAINT links_parent_id_fk;"
    execute "ALTER TABLE ONLY mappings ADD CONSTRAINT mappings_parent_id_fk FOREIGN KEY (parent_id) REFERENCES mappings(id);"
    execute "ALTER TABLE ONLY mappings DROP CONSTRAINT links_source_id_fk;"
    execute "ALTER TABLE ONLY mappings ADD CONSTRAINT mappings_source_id_fk FOREIGN KEY (source_id) REFERENCES ontologies(id);"
    execute "ALTER TABLE ONLY mappings DROP CONSTRAINT links_target_id_fk;"
    execute "ALTER TABLE ONLY mappings ADD CONSTRAINT mappings_target_id_fk FOREIGN KEY (target_id) REFERENCES ontologies(id);"
    execute "ALTER TABLE ONLY structured_proof_parts DROP CONSTRAINT structured_proof_parts_link_version_id_fk;"
    execute "ALTER TABLE ONLY structured_proof_parts ADD CONSTRAINT structured_proof_parts_mapping_version_id_fk FOREIGN KEY (mapping_version_id) REFERENCES mapping_versions(id) ON DELETE CASCADE;"
  end
  def down
    execute <<-SQL
      DROP FUNCTION fetch_distributed_graph_data(distributed_id integer);
    SQL

    execute <<-SQL
      CREATE OR REPLACE FUNCTION fetch_distributed_graph_data(distributed_id integer)
       RETURNS SETOF integer AS $$
      BEGIN
      RETURN QUERY WITH "graph_core" AS (

    SELECT "links"."id",

      "links"."target_id",

      "links"."source_id"

      FROM "links"

      WHERE "links"."ontology_id" = distributed_id),

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

    rename_column 'entities', 'symbol_group_id', 'entity_group_id'
    rename_table 'symbols', 'entities'
    rename_column 'entities_oops_responses', 'symbol_id', 'entity_id'
    rename_table 'symbols_oops_responses', 'entities_oops_responses'
    rename_column 'entities_sentences', 'symbol_id', 'entity_id'
    rename_table 'symbols_sentences', 'entities_sentences'
    rename_table 'symbol_groups', 'entity_groups'
    rename_column 'entity_mappings', 'mapping_id', 'link_id'
    rename_table 'symbol_mappings', 'entity_mappings'
    rename_column 'link_versions', 'mapping_id', 'link_id'
    rename_column 'link_versions', 'aux_mapping_id', 'aux_link_id'
    rename_table 'mapping_versions', 'link_versions'
    rename_column 'links', 'mapping_version_id', 'link_version_id'
    rename_table 'mappings', 'links'
    rename_column 'ontologies', 'symbols_count', 'entities_count'
    rename_column 'structured_proof_parts', 'mapping_version_id', 'link_version_id'
    rename_column 'translated_sentences', 'symbol_mapping_id', 'entity_mapping_id'
    execute "ALTER TABLE ONLY symbols RENAME CONSTRAINT symbols_pkey TO entities_pkey;"
    execute "ALTER TABLE ONLY symbol_groups RENAME CONSTRAINT symbol_groups_pkey TO entity_groups_pkey;"
    execute "ALTER TABLE ONLY symbol_mappings RENAME CONSTRAINT symbol_mappings_pkey TO entity_mappings_pkey;"
    execute "ALTER TABLE ONLY mapping_versions RENAME CONSTRAINT mapping_versions_pkey TO link_versions_pkey;"
    execute "ALTER TABLE ONLY mappings RENAME CONSTRAINT mappings_pkey TO links_pkey;"
    add_index 'entities', ['display_name'], unique: false, name: 'index_entities_on_display_name'
    remove_index 'entities', name: 'index_symbols_on_display_name'
    add_index 'entities', ['name'], unique: false, name: 'index_entities_on_name'
    remove_index 'entities', name: 'index_symbols_on_name'
    add_index 'entities', ['ontology_id', 'id'], unique: true, name: 'index_entities_on_ontology_id_and_id'
    remove_index 'entities', name: 'index_symbols_on_ontology_id_and_id'
    add_index 'entities', ['ontology_id', 'kind'], unique: false, name: 'index_entities_on_ontology_id_and_kind'
    remove_index 'entities', name: 'index_symbols_on_ontology_id_and_kind'
    add_index 'entities', ['ontology_id', 'text'], unique: true, name: 'index_entities_on_ontology_id_and_text'
    remove_index 'entities', name: 'index_symbols_on_ontology_id_and_text'
    add_index 'entities', ['text'], unique: false, name: 'index_entities_on_text'
    remove_index 'entities', name: 'index_symbols_on_text'
    add_index 'entities_oops_responses', ['oops_response_id', 'entity_id'], unique: true, name: 'index_entities_oops_responses_on_oops_response_id_and_entity_id'
    remove_index 'entities_oops_responses', name: 'index_symbols_oops_responses_on_oops_response_id_and_symbol_id'
    add_index 'entities_sentences', ['entity_id', 'sentence_id'], unique: false, name: 'index_entities_sentences_on_entity_id_and_sentence_id'
    remove_index 'entities_sentences', name: 'index_symbols_sentences_on_symbol_id_and_sentence_id'
    add_index 'entities_sentences', ['sentence_id', 'entity_id'], unique: true, name: 'index_entities_sentences_on_sentence_id_and_entity_id'
    remove_index 'entities_sentences', name: 'index_symbols_sentences_on_sentence_id_and_symbol_id'
    add_index 'entity_groups', ['ontology_id', 'id'], unique: true, name: 'index_entity_groups_on_ontology_id_and_id'
    remove_index 'entity_groups', name: 'index_symbol_groups_on_ontology_id_and_id'
    add_index 'entity_mappings', ['source_id'], unique: false, name: 'index_entity_mappings_on_source_id'
    remove_index 'entity_mappings', name: 'index_symbol_mappings_on_source_id'
    add_index 'entity_mappings', ['target_id'], unique: false, name: 'index_entity_mappings_on_target_id'
    remove_index 'entity_mappings', name: 'index_symbol_mappings_on_target_id'
    add_index 'link_versions', ['link_id'], unique: false, name: 'index_link_versions_on_link_id'
    remove_index 'link_versions', name: 'index_mapping_versions_on_mapping_id'
    add_index 'link_versions', ['source_id'], unique: false, name: 'index_link_versions_on_source_id'
    remove_index 'link_versions', name: 'index_mapping_versions_on_source_id'
    add_index 'link_versions', ['target_id'], unique: false, name: 'index_link_versions_on_target_id'
    remove_index 'link_versions', name: 'index_mapping_versions_on_target_id'
    add_index 'links', ['link_version_id'], unique: false, name: 'index_links_on_link_version_id'
    remove_index 'links', name: 'index_mappings_on_mapping_version_id'
    add_index 'links', ['ontology_id'], unique: false, name: 'index_links_on_ontology_id'
    remove_index 'links', name: 'index_mappings_on_ontology_id'
    add_index 'links', ['source_id'], unique: false, name: 'index_links_on_source_id'
    remove_index 'links', name: 'index_mappings_on_source_id'
    add_index 'links', ['target_id'], unique: false, name: 'index_links_on_target_id'
    remove_index 'links', name: 'index_mappings_on_target_id'
    add_index 'structured_proof_parts', ['link_version_id'], unique: false, name: 'index_structured_proof_parts_on_link_version_id'
    remove_index 'structured_proof_parts', name: 'index_structured_proof_parts_on_mapping_version_id'
    execute "ALTER TABLE ONLY symbols DROP CONSTRAINT symbols_ontology_id_fk;"
    execute "ALTER TABLE ONLY symbols ADD CONSTRAINT entities_ontology_id_fk FOREIGN KEY (ontology_id) REFERENCES ontologies(id) ON DELETE CASCADE;"
    execute "ALTER TABLE ONLY symbols_oops_responses DROP CONSTRAINT symbols_oops_responses_symbol_id_fk;"
    execute "ALTER TABLE ONLY symbols_oops_responses ADD CONSTRAINT entities_oops_responses_entity_id_fk FOREIGN KEY (entity_id) REFERENCES entities(id);"
    execute "ALTER TABLE ONLY symbols_oops_responses DROP CONSTRAINT symbols_oops_responses_oops_response_id_fk;"
    execute "ALTER TABLE ONLY symbols_oops_responses ADD CONSTRAINT entities_oops_responses_oops_response_id_fk FOREIGN KEY (oops_response_id) REFERENCES oops_responses(id) ON DELETE CASCADE;"
    execute "ALTER TABLE ONLY symbols_sentences DROP CONSTRAINT symbols_sentences_symbol_id_fk;"
    execute "ALTER TABLE ONLY symbols_sentences ADD CONSTRAINT entities_sentences_entity_id_fk FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE;"
    execute "ALTER TABLE ONLY symbols_sentences DROP CONSTRAINT symbols_sentences_ontology_id_fk;"
    execute "ALTER TABLE ONLY symbols_sentences ADD CONSTRAINT entities_sentences_ontology_id_fk FOREIGN KEY (ontology_id) REFERENCES ontologies(id) ON DELETE CASCADE;"
    execute "ALTER TABLE ONLY symbols_sentences DROP CONSTRAINT symbols_sentences_sentence_id_fk;"
    execute "ALTER TABLE ONLY symbols_sentences ADD CONSTRAINT entities_sentences_sentence_id_fk FOREIGN KEY (sentence_id) REFERENCES sentences(id) ON DELETE CASCADE;"
    execute "ALTER TABLE ONLY symbol_groups DROP CONSTRAINT symbol_groups_ontology_id_fk;"
    execute "ALTER TABLE ONLY symbol_groups ADD CONSTRAINT entity_groups_ontology_id_fk FOREIGN KEY (ontology_id) REFERENCES ontologies(id) ON DELETE CASCADE;"
    execute "ALTER TABLE ONLY symbol_mappings DROP CONSTRAINT symbol_mappings_source_id_fk;"
    execute "ALTER TABLE ONLY symbol_mappings ADD CONSTRAINT entity_mappings_source_id_fk FOREIGN KEY (source_id) REFERENCES entities(id) ON DELETE CASCADE;"
    execute "ALTER TABLE ONLY symbol_mappings DROP CONSTRAINT symbol_mappings_target_id_fk;"
    execute "ALTER TABLE ONLY symbol_mappings ADD CONSTRAINT entity_mappings_target_id_fk FOREIGN KEY (target_id) REFERENCES entities(id) ON DELETE CASCADE;"
    execute "ALTER TABLE ONLY mapping_versions DROP CONSTRAINT mapping_versions_mapping_id_fk;"
    execute "ALTER TABLE ONLY mapping_versions ADD CONSTRAINT link_versions_link_id_fk FOREIGN KEY (link_id) REFERENCES links(id) ON DELETE CASCADE;"
    execute "ALTER TABLE ONLY mapping_versions DROP CONSTRAINT mapping_versions_source_id_fk;"
    execute "ALTER TABLE ONLY mapping_versions ADD CONSTRAINT link_versions_source_id_fk FOREIGN KEY (source_id) REFERENCES ontology_versions(id) ON DELETE CASCADE;"
    execute "ALTER TABLE ONLY mapping_versions DROP CONSTRAINT mapping_versions_target_id_fk;"
    execute "ALTER TABLE ONLY mapping_versions ADD CONSTRAINT link_versions_target_id_fk FOREIGN KEY (target_id) REFERENCES ontology_versions(id) ON DELETE CASCADE;"
    execute "ALTER TABLE ONLY mappings DROP CONSTRAINT mappings_ontology_id_fk;"
    execute "ALTER TABLE ONLY mappings ADD CONSTRAINT links_ontology_id_fk FOREIGN KEY (ontology_id) REFERENCES ontologies(id) ON DELETE CASCADE;"
    execute "ALTER TABLE ONLY mappings DROP CONSTRAINT mappings_parent_id_fk;"
    execute "ALTER TABLE ONLY mappings ADD CONSTRAINT links_parent_id_fk FOREIGN KEY (parent_id) REFERENCES links(id);"
    execute "ALTER TABLE ONLY mappings DROP CONSTRAINT mappings_source_id_fk;"
    execute "ALTER TABLE ONLY mappings ADD CONSTRAINT links_source_id_fk FOREIGN KEY (source_id) REFERENCES ontologies(id);"
    execute "ALTER TABLE ONLY mappings DROP CONSTRAINT mappings_target_id_fk;"
    execute "ALTER TABLE ONLY mappings ADD CONSTRAINT links_target_id_fk FOREIGN KEY (target_id) REFERENCES ontologies(id);"
    execute "ALTER TABLE ONLY structured_proof_parts DROP CONSTRAINT structured_proof_parts_mapping_version_id_fk;"
    execute "ALTER TABLE ONLY structured_proof_parts ADD CONSTRAINT structured_proof_parts_link_version_id_fk FOREIGN KEY (link_version_id) REFERENCES link_versions(id) ON DELETE CASCADE;"
  end
end

