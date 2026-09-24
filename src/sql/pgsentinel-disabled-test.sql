CREATE EXTENSION pg_stat_statements;
CREATE EXTENSION pgsentinel;

select pg_sleep(3);
select count(*) > 0 AS has_data from pg_active_session_history where queryid in (select queryid from pg_stat_statements);
select count(*) > 0 AS has_pgssh_data from pg_stat_statements_history;

-- YB: tests for pgsentinel_ash.yb_track_query_text
-- With pgsentinel_ash.yb_track_query_text off, no query text is stored.
SHOW pgsentinel_ash.yb_track_query_text;
select count(*) = 0 AS no_ash_query_text from pg_active_session_history
where query is not null or top_level_query is not null;
select count(*) = 0 AS no_gpi_query_text from get_parsedinfo(-1)
where query is not null;

-- The text can still be looked up in pg_stat_statements by queryid.
select count(*) > 0 AS has_pgss_query_text
from pg_active_session_history ash join pg_stat_statements pgss using (queryid)
where pgss.query like 'select pg_sleep(%';

-- No shared memory is reserved for query text (pg_shmem_allocations is PG 13+).
CREATE FUNCTION yb_no_query_text_buffers() RETURNS boolean AS $$
DECLARE
  n bigint := 0;
BEGIN
  IF current_setting('server_version_num')::integer >= 130000 THEN
    EXECUTE $q$SELECT count(*) FROM pg_shmem_allocations
               WHERE name IN ('Ash Entry Query Buffer',
                              'Ash Entry Top Level Query Buffer',
                              'Proc Query Buffer')$q$ INTO n;
  END IF;
  RETURN n = 0;
END;
$$ LANGUAGE plpgsql;
SELECT yb_no_query_text_buffers();
DROP FUNCTION yb_no_query_text_buffers();

DROP EXTENSION pgsentinel;
DROP EXTENSION pg_stat_statements;
