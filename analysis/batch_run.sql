-- check batch runs
SELECT * FROM raw.batch_runs;

-- check new rows in raw (batch 1)
SELECT COUNT(*) FROM raw.raw_fifa_wc WHERE batch_id = 1;

-- check total rows now
SELECT COUNT(*) FROM raw.raw_fifa_wc;
SELECT COUNT(*) FROM stg.stg_fifa_wc;
SELECT COUNT(*) FROM final.fact_match;