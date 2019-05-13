-- Generated by CompileSchemaScripts.pl from:
-- 20170604-mbs-9365.sql
-- 20170909-mbs-9462-missing-event-triggers.sql
-- 20180331-mbs-9664-non-loop-checks.sql
-- 20190317-mbs-9941-mbs-10062-fks.sql
-- 20190422-mbs-9428-collection-collaborators-fks.sql
-- 20190423-mbs-10052-eaa-standalone.sql
\set ON_ERROR_STOP 1
BEGIN;
SET search_path = musicbrainz, public;
SET LOCAL statement_timeout = 0;
--------------------------------------------------------------------------------
SELECT '20170604-mbs-9365.sql';

ALTER TABLE event_meta DROP CONSTRAINT IF EXISTS event_meta_fk_id;

ALTER TABLE event_meta
   ADD CONSTRAINT event_meta_fk_id
   FOREIGN KEY (id)
   REFERENCES event(id)
   ON DELETE CASCADE;

--------------------------------------------------------------------------------
SELECT '20170909-mbs-9462-missing-event-triggers.sql';

DROP TRIGGER IF EXISTS b_upd_l_event_url ON l_event_url;
DROP TRIGGER IF EXISTS remove_unused_links ON l_event_url;
DROP TRIGGER IF EXISTS url_gc_a_del_l_event_url ON l_event_url;
DROP TRIGGER IF EXISTS url_gc_a_upd_l_event_url ON l_event_url;

CREATE TRIGGER b_upd_l_event_url
    BEFORE UPDATE ON l_event_url
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_event_url DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER url_gc_a_del_l_event_url
    AFTER DELETE ON l_event_url DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

CREATE CONSTRAINT TRIGGER url_gc_a_upd_l_event_url
    AFTER UPDATE ON l_event_url DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

--------------------------------------------------------------------------------
SELECT '20180331-mbs-9664-non-loop-checks.sql';

ALTER TABLE l_area_area                   ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);
ALTER TABLE l_artist_artist               ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);
ALTER TABLE l_event_event                 ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);
ALTER TABLE l_label_label                 ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);
ALTER TABLE l_instrument_instrument       ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);
ALTER TABLE l_place_place                 ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);
ALTER TABLE l_recording_recording         ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);
ALTER TABLE l_release_release             ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);
ALTER TABLE l_release_group_release_group ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);
ALTER TABLE l_series_series               ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);
ALTER TABLE l_url_url                     ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);
ALTER TABLE l_work_work                   ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);

--------------------------------------------------------------------------------
SELECT '20190317-mbs-9941-mbs-10062-fks.sql';

ALTER TABLE genre_alias
   ADD CONSTRAINT genre_alias_fk_genre
   FOREIGN KEY (genre)
   REFERENCES genre(id);

CREATE TRIGGER b_upd_genre BEFORE UPDATE ON genre
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_genre_alias BEFORE UPDATE ON genre_alias
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER unique_primary_for_locale BEFORE UPDATE OR INSERT ON genre_alias
    FOR EACH ROW EXECUTE PROCEDURE unique_primary_genre_alias();

--------------------------------------------------------------------------------
SELECT '20190422-mbs-9428-collection-collaborators-fks.sql';

ALTER TABLE editor_collection_collaborator
   ADD CONSTRAINT editor_collection_collaborator_fk_collection
   FOREIGN KEY (collection)
   REFERENCES editor_collection(id);

ALTER TABLE editor_collection_collaborator
   ADD CONSTRAINT editor_collection_collaborator_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

--------------------------------------------------------------------------------
SELECT '20190423-mbs-10052-eaa-standalone.sql';

SET search_path = 'event_art_archive';

-- Foreign keys

ALTER TABLE event_art
   ADD CONSTRAINT event_art_fk_edit
   FOREIGN KEY (edit)
   REFERENCES musicbrainz.edit(id);

ALTER TABLE art_type
   ADD CONSTRAINT art_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES event_art_archive.art_type(id);

ALTER TABLE event_art
   ADD CONSTRAINT event_art_fk_event
   FOREIGN KEY (event)
   REFERENCES musicbrainz.event(id)
   ON DELETE CASCADE;

ALTER TABLE event_art
   ADD CONSTRAINT event_art_fk_mime_type
   FOREIGN KEY (mime_type)
   REFERENCES cover_art_archive.image_type(mime_type);

ALTER TABLE event_art_type
   ADD CONSTRAINT event_art_type_fk_id
   FOREIGN KEY (id)
   REFERENCES event_art_archive.event_art(id)
   ON DELETE CASCADE;

ALTER TABLE event_art_type
   ADD CONSTRAINT event_art_type_fk_type_id
   FOREIGN KEY (type_id)
   REFERENCES event_art_archive.art_type(id);

-- Triggers

CREATE TRIGGER update_event_art AFTER INSERT OR DELETE
ON event_art_archive.event_art
FOR EACH ROW EXECUTE PROCEDURE materialize_eaa_presence();

CREATE CONSTRAINT TRIGGER resquence_event_art AFTER INSERT OR UPDATE OR DELETE
ON event_art_archive.event_art DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE resequence_event_art_trigger();

COMMIT;
