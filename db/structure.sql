CREATE TABLE `comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `commentable_id` int(11) NOT NULL,
  `commentable_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `user_id` int(11) NOT NULL,
  `text` text COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_comments_on_commentable_and_id` (`commentable_id`,`commentable_type`,`id`),
  KEY `index_comments_on_user_id` (`user_id`),
  CONSTRAINT `comments_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `entities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ontology_version_id` int(11) NOT NULL,
  `kind` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `text` text COLLATE utf8_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `uri` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `range` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `comments_count` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_entities_on_ontology_version_id_and_id` (`ontology_version_id`,`id`),
  KEY `index_entities_on_ontology_version_id_and_kind` (`ontology_version_id`,`kind`),
  CONSTRAINT `entities_ontology_version_id_fk` FOREIGN KEY (`ontology_version_id`) REFERENCES `ontology_versions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `entity_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `link_version_id` int(11) NOT NULL,
  `source_id` int(11) NOT NULL,
  `target_id` int(11) NOT NULL,
  `confidence` int(11) DEFAULT NULL,
  `kind` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_entity_mappings_on_link_version_id` (`link_version_id`),
  KEY `index_entity_mappings_on_source_id` (`source_id`),
  KEY `index_entity_mappings_on_target_id` (`target_id`),
  CONSTRAINT `entity_mappings_target_id_fk` FOREIGN KEY (`target_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE,
  CONSTRAINT `entity_mappings_link_version_id_fk` FOREIGN KEY (`link_version_id`) REFERENCES `link_versions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `entity_mappings_source_id_fk` FOREIGN KEY (`source_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `language_adjoints` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `translation_id` int(11) NOT NULL,
  `projection_id` int(11) NOT NULL,
  `iri` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `kind` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_language_adjoints_on_translation_id` (`translation_id`),
  KEY `index_language_adjoints_on_projection_id` (`projection_id`),
  CONSTRAINT `language_adjoints_projection_id_fk` FOREIGN KEY (`projection_id`) REFERENCES `language_mappings` (`id`) ON DELETE CASCADE,
  CONSTRAINT `language_adjoints_translation_id_fk` FOREIGN KEY (`translation_id`) REFERENCES `language_mappings` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `language_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `source_id` int(11) NOT NULL,
  `target_id` int(11) NOT NULL,
  `iri` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `kind` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_language_mappings_on_source_id` (`source_id`),
  KEY `index_language_mappings_on_target_id` (`target_id`),
  CONSTRAINT `language_mappings_target_id_fk` FOREIGN KEY (`target_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE,
  CONSTRAINT `language_mappings_source_id_fk` FOREIGN KEY (`source_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `languages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `iri` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_languages_on_name` (`name`),
  UNIQUE KEY `index_languages_on_iri` (`iri`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `link_versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `link_id` int(11) NOT NULL,
  `source_id` int(11) NOT NULL,
  `target_id` int(11) NOT NULL,
  `version_number` int(11) DEFAULT NULL,
  `current` tinyint(1) DEFAULT NULL,
  `proof_status` tinyint(1) DEFAULT NULL,
  `couse_status` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_link_versions_on_link_id` (`link_id`),
  KEY `index_link_versions_on_source_id` (`source_id`),
  KEY `index_link_versions_on_target_id` (`target_id`),
  CONSTRAINT `link_versions_target_id_fk` FOREIGN KEY (`target_id`) REFERENCES `ontology_versions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `link_versions_link_id_fk` FOREIGN KEY (`link_id`) REFERENCES `links` (`id`) ON DELETE CASCADE,
  CONSTRAINT `link_versions_source_id_fk` FOREIGN KEY (`source_id`) REFERENCES `ontology_versions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `links` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `source_id` int(11) NOT NULL,
  `target_id` int(11) NOT NULL,
  `kind` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_links_on_source_id` (`source_id`),
  KEY `index_links_on_target_id` (`target_id`),
  CONSTRAINT `links_target_id_fk` FOREIGN KEY (`target_id`) REFERENCES `ontologies` (`id`),
  CONSTRAINT `links_source_id_fk` FOREIGN KEY (`source_id`) REFERENCES `ontologies` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `logic_adjoints` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `translation_id` int(11) NOT NULL,
  `projection_id` int(11) NOT NULL,
  `iri` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `kind` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_logic_adjoints_on_translation_id` (`translation_id`),
  KEY `index_logic_adjoints_on_projection_id` (`projection_id`),
  CONSTRAINT `logic_adjoints_projection_id_fk` FOREIGN KEY (`projection_id`) REFERENCES `logic_mappings` (`id`) ON DELETE CASCADE,
  CONSTRAINT `logic_adjoints_translation_id_fk` FOREIGN KEY (`translation_id`) REFERENCES `logic_mappings` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `logic_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `source_id` int(11) NOT NULL,
  `target_id` int(11) NOT NULL,
  `iri` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `kind` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_logic_mappings_on_source_id` (`source_id`),
  KEY `index_logic_mappings_on_target_id` (`target_id`),
  CONSTRAINT `logic_mappings_target_id_fk` FOREIGN KEY (`target_id`) REFERENCES `logics` (`id`) ON DELETE CASCADE,
  CONSTRAINT `logic_mappings_source_id_fk` FOREIGN KEY (`source_id`) REFERENCES `logics` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `logics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `iri` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_logics_on_name` (`name`),
  UNIQUE KEY `index_logics_on_iri` (`iri`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `members` (
  `ontology_version_id` int(11) NOT NULL,
  `distributed_ontology_version_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `metadata` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `metadatable_id` int(11) DEFAULT NULL,
  `metadatable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_metadata_on_metadatable_id_and_metadatable_type` (`metadatable_id`,`metadatable_type`),
  KEY `index_metadata_on_user_id` (`user_id`),
  CONSTRAINT `metadata_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `ontologies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `language_id` int(11) DEFAULT NULL,
  `uri` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `state` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'pending',
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `distributed` tinyint(1) DEFAULT '0',
  `entities_count` int(11) DEFAULT NULL,
  `axioms_count` int(11) DEFAULT NULL,
  `versions_count` int(11) NOT NULL DEFAULT '0',
  `metadata_count` int(11) NOT NULL DEFAULT '0',
  `comments_count` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_ontologies_on_uri` (`uri`),
  KEY `index_ontologies_on_state` (`state`),
  KEY `index_ontologies_on_language_id` (`language_id`),
  CONSTRAINT `ontologies_language_id_fk` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `ontology_versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `ontology_id` int(11) NOT NULL,
  `previous_version_id` int(11) DEFAULT NULL,
  `source_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `raw_file` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `xml_file` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state` varchar(255) COLLATE utf8_unicode_ci DEFAULT 'pending',
  `last_error` text COLLATE utf8_unicode_ci,
  `checksum` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `number` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_ontology_versions_on_ontology_id_and_number` (`ontology_id`,`number`),
  KEY `index_ontology_versions_on_user_id` (`user_id`),
  KEY `index_ontology_versions_on_checksum` (`checksum`),
  KEY `index_ontology_versions_on_previous_version_id` (`previous_version_id`),
  CONSTRAINT `ontology_versions_previous_version_id_fk` FOREIGN KEY (`previous_version_id`) REFERENCES `ontology_versions` (`id`),
  CONSTRAINT `ontology_versions_ontology_id_fk` FOREIGN KEY (`ontology_id`) REFERENCES `ontologies` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ontology_versions_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subject_id` int(11) NOT NULL,
  `subject_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `item_id` int(11) NOT NULL,
  `item_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `creator_id` int(11) DEFAULT NULL,
  `role` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'editor',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_permissions_on_item_and_subject` (`item_id`,`item_type`,`subject_id`,`subject_type`),
  KEY `index_permissions_on_subject_id_and_subject_type` (`subject_id`,`subject_type`),
  KEY `index_permissions_on_creator_id` (`creator_id`),
  CONSTRAINT `permissions_creator_id_fk` FOREIGN KEY (`creator_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `sentence_has_entities` (
  `sentence_id` int(11) NOT NULL,
  `entity_id` int(11) NOT NULL,
  `ontology_version_id` int(11) NOT NULL,
  UNIQUE KEY `index_sentence_has_entities_on_sentence_id_and_entity_id` (`sentence_id`,`entity_id`),
  KEY `index_sentence_has_entities_on_entity_id_and_sentence_id` (`entity_id`,`sentence_id`),
  CONSTRAINT `sentence_has_entities_sentence_id_fk` FOREIGN KEY (`sentence_id`) REFERENCES `sentences` (`id`) ON DELETE CASCADE,
  CONSTRAINT `sentence_has_entities_entity_id_fk` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `sentences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ontology_version_id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `text` text COLLATE utf8_unicode_ci NOT NULL,
  `range` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `comments_count` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_sentences_on_ontology_version_id_and_id` (`ontology_version_id`,`id`),
  UNIQUE KEY `index_sentences_on_ontology_version_id_and_name` (`ontology_version_id`,`name`),
  CONSTRAINT `sentences_ontology_version_id_fk` FOREIGN KEY (`ontology_version_id`) REFERENCES `ontology_versions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `serializations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `extension` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `mimetype` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `language_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_serializations_on_language_id` (`language_id`),
  CONSTRAINT `serializations_language_id_fk` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `supports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `language_id` int(11) DEFAULT NULL,
  `logic_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_supports_on_language_id` (`language_id`),
  KEY `index_supports_on_logic_id` (`logic_id`),
  CONSTRAINT `supports_logic_id_fk` FOREIGN KEY (`logic_id`) REFERENCES `logics` (`id`),
  CONSTRAINT `supports_language_id_fk` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `team_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `team_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `creator_id` int(11) DEFAULT NULL,
  `admin` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_team_users_on_team_id_and_user_id` (`team_id`,`user_id`),
  KEY `index_team_users_on_user_id` (`user_id`),
  KEY `index_team_users_on_creator_id` (`creator_id`),
  CONSTRAINT `team_users_creator_id_fk` FOREIGN KEY (`creator_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `team_users_team_id_fk` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE CASCADE,
  CONSTRAINT `team_users_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `teams` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_teams_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `encrypted_password` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reset_password_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(11) DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `confirmation_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `confirmed_at` datetime DEFAULT NULL,
  `confirmation_sent_at` datetime DEFAULT NULL,
  `unconfirmed_email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `failed_attempts` int(11) DEFAULT '0',
  `unlock_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `admin` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_email` (`email`),
  UNIQUE KEY `index_users_on_reset_password_token` (`reset_password_token`),
  UNIQUE KEY `index_users_on_unlock_token` (`unlock_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO schema_migrations (version) VALUES ('20120000000001');

INSERT INTO schema_migrations (version) VALUES ('20120307103820');

INSERT INTO schema_migrations (version) VALUES ('20120307142053');

INSERT INTO schema_migrations (version) VALUES ('20120307143552');

INSERT INTO schema_migrations (version) VALUES ('20120307143553');

INSERT INTO schema_migrations (version) VALUES ('20120307152347');

INSERT INTO schema_migrations (version) VALUES ('20120307152935');

INSERT INTO schema_migrations (version) VALUES ('20120307154214');

INSERT INTO schema_migrations (version) VALUES ('20120307163615');

INSERT INTO schema_migrations (version) VALUES ('20120307165334');

INSERT INTO schema_migrations (version) VALUES ('20120308144854');

INSERT INTO schema_migrations (version) VALUES ('20120308144855');

INSERT INTO schema_migrations (version) VALUES ('20120308144859');

INSERT INTO schema_migrations (version) VALUES ('20120313131338');

INSERT INTO schema_migrations (version) VALUES ('20120416185310');

INSERT INTO schema_migrations (version) VALUES ('20120416190216');

INSERT INTO schema_migrations (version) VALUES ('20120416191514');

INSERT INTO schema_migrations (version) VALUES ('20120416192741');

INSERT INTO schema_migrations (version) VALUES ('20120419190000');

INSERT INTO schema_migrations (version) VALUES ('20120424155606');

INSERT INTO schema_migrations (version) VALUES ('20120424155621');

INSERT INTO schema_migrations (version) VALUES ('20120424162211');

INSERT INTO schema_migrations (version) VALUES ('20120424162227');