-- ============================================================
-- Lesson 03 — Indexes: Class Exercises
-- Work through these before looking at the hints
-- ============================================================

-- ============================================================
-- Exercise 1 — Identify the slow query
--
-- Execute this query and inspect the execution plan.
-- Is Oracle using an index? Should it?
-- ============================================================

EXPLAIN PLAN FOR
SELECT * FROM patient_visits WHERE site_id = 3;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Questions:
-- a) What scan type do you see? Why?
--
-- Full Table Scan, since there is no index on site_id, so the
-- database determines that scanning the entire table is cheaper
--
-- b) site_id has values 1–5. Is this high or low cardinality?
--
-- Low cardinality
--
-- c) Would adding an index on site_id help? Why or why not?
--
-- No, because many rows share the same value (low cardinality),
-- which results in low selectivity. The DB will likely still
-- favor a Full Table Scan.

-- ============================================================
-- Exercise 2 — Create an index and evaluate it
--
-- Create an index on visit_date.
-- Then run the range query below and inspect the plan.
-- ============================================================

-- Step 1: Create it
-- (write the CREATE INDEX statement here)


-- Step 2: Gather stats
BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'PATIENT_VISITS', cascade => TRUE);
END;
/

-- Step 3: Run the range query and inspect the plan
EXPLAIN PLAN FOR
SELECT * FROM patient_visits
WHERE visit_date BETWEEN SYSDATE - 30 AND SYSDATE;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Questions:
-- a) Does Oracle use the index for this range?
--
-- Yes, because 30 days is a relatively small range compared to the
-- total data. With fewer rows to retrieve, the index efficiently
-- narrows down the search.
--
-- b) Change the range to the last 7 days. Does the plan change?
--
-- It still uses the index, since selectivity is even higher.
--
-- c) Change to the last 700 days. What happens?
--
-- The database switches to a full table scan, because using the
-- index would involve many scattered accesses, which are slower overall.
--
-- d) Why does the range size affect index usage?
--
-- A full scan is sequential and efficient. Index access is only
-- beneficial when retrieving a small subset of rows, since each
-- indexed lookup is comparatively more expensive.

-- ============================================================
-- Exercise 3 — Composite index
--
-- You often query by both patient_id AND visit_date together:
--   WHERE patient_id = 1234 AND visit_date > SYSDATE - 90
--
-- Two options:
--   Option A: Two separate indexes (one per column)
--   Option B: One composite index (patient_id, visit_date)
--
-- Create the composite index and test the query.
-- ============================================================

CREATE INDEX idx_pv_patient_date ON patient_visits(patient_id, visit_date);

BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'PATIENT_VISITS', cascade => TRUE);
END;
/

EXPLAIN PLAN FOR
SELECT * FROM patient_visits
WHERE patient_id = 1234
  AND visit_date > SYSDATE - 90;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Questions:
-- a) Does the plan use the composite index?
--
-- Yes, because the query uses the leading column `patient_id`.
-- The DB can quickly locate rows with patient_id = 1234 and then
-- filter by the date range.
--
-- b) Now try querying ONLY on visit_date (no patient_id).
--    Does the composite index get used? Why not?
--
-- No. Without specifying patient_id, the DB would need to scan
-- across all groups, making a full table scan more efficient.
--
-- c) What's the rule about column order in composite indexes?
--
-- Leftmost prefix rule: a composite index is only usable starting
-- from the first column.
-- “you must start from the first column, but you can stop early”

-- Bonus test — leading column only:
EXPLAIN PLAN FOR
SELECT * FROM patient_visits WHERE patient_id = 1234;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Trailing column only (index cannot be used from the middle):
EXPLAIN PLAN FOR
SELECT * FROM patient_visits WHERE visit_date > SYSDATE - 90;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- ============================================================
-- Exercise 4 — Function that disables an index
--
-- There IS an index on patient_id (from lesson 03).
-- Predict what happens when applying a function to the column.
-- ============================================================

-- This query CAN use the index:
EXPLAIN PLAN FOR
SELECT * FROM patient_visits WHERE patient_id = 5432;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- This one cannot — why?
EXPLAIN PLAN FOR
SELECT * FROM patient_visits WHERE TO_CHAR(patient_id) = '5432';
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Questions:
-- a) What scan type did the second query use?
--
-- Full table scan.
--
-- b) Why does wrapping a column in a function break index use?
--
-- Because the index stores the original column values, not the
-- result of applying a function.
--
-- c) How would you rewrite the second query to allow index use?

-- Works for deterministic functions

CREATE INDEX idx_pv_pid_char
ON patient_visits(TO_CHAR(patient_id));

SELECT * FROM patient_visits WHERE TO_CHAR(patient_id) = '5432';

-- ============================================================
-- Exercise 5 — Discussion: real-world scenarios
--
-- For each scenario below, decide:
--   a) Would you add an index?
--   b) On which column(s)?
--   c) Any concerns?
-- ============================================================

-- Scenario A:
-- A reporting table gets loaded once per night (batch ETL).
-- During the day, analysts run SELECT queries by date range.
-- The table has 50 million rows.
-- → Index on date? Yes/No, why?

-- a) Yes
-- b) visit_date
-- c) No major concerns.

-- Scenario B:
-- An OLTP orders table gets 10,000 inserts per minute.
-- Support staff look up orders by customer_id or order_status.
-- order_status has 4 values: pending, processing, shipped, cancelled.
-- → What indexes would you add?

-- a) Yes, but mainly for customer_id, and only if lookups are frequent.
-- If read performance is not critical, avoid indexes due to write cost.
-- b) customer_id
-- c) Indexes slow down inserts, and the system must handle high throughput.
-- Also, order_status has low cardinality, so indexing it is less useful.

-- Scenario C:
-- A patient table has an email column (unique per patient).
-- There are 5 million patients.
-- The app frequently does: WHERE email = 'user@example.com'
-- → What kind of index would be best here?

-- a) Yes
-- b) email
-- c) High cardinality makes it ideal.

-- Best index is a Unique Index
