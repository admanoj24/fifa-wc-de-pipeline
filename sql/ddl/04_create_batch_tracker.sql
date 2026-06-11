ALTER TABLE raw.raw_fifa_wc ADD COLUMN IF NOT EXISTS batch_id INT;

UPDATE raw.raw_fifa_wc SET batch_id = 0 WHERE batch_id IS NULL;

CREATE TABLE IF NOT EXISTS raw.batch_runs (
    batch_id      SERIAL PRIMARY KEY,
    status        TEXT NOT NULL CHECK (status IN ('pending', 'running', 'success', 'failed')),
    start_time    TIMESTAMP,
    end_time      TIMESTAMP,
    error_message TEXT
);