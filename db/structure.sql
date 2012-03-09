--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: axioms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE axioms (
    id integer NOT NULL,
    ontology_id integer NOT NULL,
    name character varying(255) NOT NULL,
    text character varying(255) NOT NULL,
    range character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: axioms_entities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE axioms_entities (
    axiom_id integer NOT NULL,
    entity_id integer NOT NULL,
    ontology_id integer NOT NULL
);


--
-- Name: axioms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE axioms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: axioms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE axioms_id_seq OWNED BY axioms.id;


--
-- Name: entities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE entities (
    id integer NOT NULL,
    ontology_id integer NOT NULL,
    kind character varying(255),
    text character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    uri character varying(255),
    range character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: entities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE entities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE entities_id_seq OWNED BY entities.id;


--
-- Name: links; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE links (
    id integer NOT NULL,
    source_id integer NOT NULL,
    target_id integer NOT NULL,
    kind character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE links_id_seq OWNED BY links.id;


--
-- Name: logics; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE logics (
    id integer NOT NULL,
    name character varying(255),
    uri character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: logics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE logics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: logics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE logics_id_seq OWNED BY logics.id;


--
-- Name: metadata; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE metadata (
    id integer NOT NULL,
    metadatable_id integer,
    metadatable_type character varying(255),
    key character varying(255),
    value character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: metadata_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE metadata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE metadata_id_seq OWNED BY metadata.id;


--
-- Name: ontologies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ontologies (
    id integer NOT NULL,
    logic_id integer,
    uri character varying(255) NOT NULL,
    state character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    name character varying(255),
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ontologies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ontologies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ontologies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ontologies_id_seq OWNED BY ontologies.id;


--
-- Name: ontology_versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ontology_versions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    ontology_id integer NOT NULL,
    source_uri character varying(255),
    raw_file_name character varying(255),
    raw_file_size integer,
    xml_file_name character varying(255),
    xml_file_size integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ontology_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ontology_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ontology_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ontology_versions_id_seq OWNED BY ontology_versions.id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE permissions (
    id integer NOT NULL,
    subject_id integer NOT NULL,
    subject_type character varying(255) NOT NULL,
    item_id integer NOT NULL,
    item_type character varying(255) NOT NULL,
    role character varying(255) DEFAULT 'editor'::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE permissions_id_seq OWNED BY permissions.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: team_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE team_users (
    id integer NOT NULL,
    team_id integer,
    user_id integer,
    admin boolean DEFAULT false NOT NULL
);


--
-- Name: team_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE team_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE team_users_id_seq OWNED BY team_users.id;


--
-- Name: teams; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE teams (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE teams_id_seq OWNED BY teams.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255),
    encrypted_password character varying(255),
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    confirmation_token character varying(255),
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying(255),
    failed_attempts integer DEFAULT 0,
    unlock_token character varying(255),
    locked_at timestamp without time zone,
    name character varying(255),
    admin boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY axioms ALTER COLUMN id SET DEFAULT nextval('axioms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY entities ALTER COLUMN id SET DEFAULT nextval('entities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY links ALTER COLUMN id SET DEFAULT nextval('links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY logics ALTER COLUMN id SET DEFAULT nextval('logics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY metadata ALTER COLUMN id SET DEFAULT nextval('metadata_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ontologies ALTER COLUMN id SET DEFAULT nextval('ontologies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ontology_versions ALTER COLUMN id SET DEFAULT nextval('ontology_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY permissions ALTER COLUMN id SET DEFAULT nextval('permissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY team_users ALTER COLUMN id SET DEFAULT nextval('team_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY teams ALTER COLUMN id SET DEFAULT nextval('teams_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: axioms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY axioms
    ADD CONSTRAINT axioms_pkey PRIMARY KEY (id);


--
-- Name: entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY entities
    ADD CONSTRAINT entities_pkey PRIMARY KEY (id);


--
-- Name: links_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: logics_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY logics
    ADD CONSTRAINT logics_pkey PRIMARY KEY (id);


--
-- Name: metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY metadata
    ADD CONSTRAINT metadata_pkey PRIMARY KEY (id);


--
-- Name: ontologies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ontologies
    ADD CONSTRAINT ontologies_pkey PRIMARY KEY (id);


--
-- Name: ontology_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ontology_versions
    ADD CONSTRAINT ontology_versions_pkey PRIMARY KEY (id);


--
-- Name: permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: team_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY team_users
    ADD CONSTRAINT team_users_pkey PRIMARY KEY (id);


--
-- Name: teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_axioms_entities_on_axiom_id_and_entity_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_axioms_entities_on_axiom_id_and_entity_id ON axioms_entities USING btree (axiom_id, entity_id);


--
-- Name: index_axioms_entities_on_entity_id_and_axiom_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_axioms_entities_on_entity_id_and_axiom_id ON axioms_entities USING btree (entity_id, axiom_id);


--
-- Name: index_axioms_on_ontology_id_and_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_axioms_on_ontology_id_and_id ON axioms USING btree (ontology_id, id);


--
-- Name: index_axioms_on_ontology_id_and_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_axioms_on_ontology_id_and_name ON axioms USING btree (ontology_id, name);


--
-- Name: index_entities_on_ontology_id_and_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_entities_on_ontology_id_and_id ON entities USING btree (ontology_id, id);


--
-- Name: index_entities_on_ontology_id_and_text; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_entities_on_ontology_id_and_text ON entities USING btree (ontology_id, text);


--
-- Name: index_links_on_source_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_links_on_source_id ON links USING btree (source_id);


--
-- Name: index_links_on_target_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_links_on_target_id ON links USING btree (target_id);


--
-- Name: index_metadata_on_metadatable_id_and_metadatable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_metadata_on_metadatable_id_and_metadatable_type ON metadata USING btree (metadatable_id, metadatable_type);


--
-- Name: index_ontologies_on_logic_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ontologies_on_logic_id ON ontologies USING btree (logic_id);


--
-- Name: index_ontology_versions_on_ontology_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ontology_versions_on_ontology_id ON ontology_versions USING btree (ontology_id);


--
-- Name: index_ontology_versions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ontology_versions_on_user_id ON ontology_versions USING btree (user_id);


--
-- Name: index_permissions_on_item_and_subject; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_permissions_on_item_and_subject ON permissions USING btree (item_id, item_type, subject_id, subject_type);


--
-- Name: index_permissions_on_subject_id_and_subject_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_permissions_on_subject_id_and_subject_type ON permissions USING btree (subject_id, subject_type);


--
-- Name: index_team_users_on_team_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_team_users_on_team_id_and_user_id ON team_users USING btree (team_id, user_id);


--
-- Name: index_teams_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_teams_on_name ON teams USING btree (name);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_unlock_token ON users USING btree (unlock_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: axioms_entities_axiom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY axioms_entities
    ADD CONSTRAINT axioms_entities_axiom_id_fkey FOREIGN KEY (axiom_id, ontology_id) REFERENCES axioms(id, ontology_id) ON DELETE CASCADE;


--
-- Name: axioms_entities_entity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY axioms_entities
    ADD CONSTRAINT axioms_entities_entity_id_fkey FOREIGN KEY (entity_id, ontology_id) REFERENCES entities(id, ontology_id) ON DELETE CASCADE;


--
-- Name: axioms_ontology_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY axioms
    ADD CONSTRAINT axioms_ontology_id_fk FOREIGN KEY (ontology_id) REFERENCES ontologies(id) ON DELETE CASCADE;


--
-- Name: entities_ontology_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entities
    ADD CONSTRAINT entities_ontology_id_fk FOREIGN KEY (ontology_id) REFERENCES ontologies(id) ON DELETE CASCADE;


--
-- Name: links_source_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_source_id_fk FOREIGN KEY (source_id) REFERENCES ontologies(id);


--
-- Name: links_target_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_target_id_fk FOREIGN KEY (target_id) REFERENCES ontologies(id);


--
-- Name: ontologies_logic_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ontologies
    ADD CONSTRAINT ontologies_logic_id_fk FOREIGN KEY (logic_id) REFERENCES logics(id);


--
-- Name: ontology_versions_ontology_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ontology_versions
    ADD CONSTRAINT ontology_versions_ontology_id_fk FOREIGN KEY (ontology_id) REFERENCES ontologies(id) ON DELETE CASCADE;


--
-- Name: ontology_versions_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ontology_versions
    ADD CONSTRAINT ontology_versions_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: team_users_team_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY team_users
    ADD CONSTRAINT team_users_team_id_fk FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE;


--
-- Name: team_users_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY team_users
    ADD CONSTRAINT team_users_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

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