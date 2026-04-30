# 2026-04-29

## Topics covered

- Database indexes
- Full table scan vs index scan
- Index range scans
- Composite indexes
- Leftmost prefix rule
- Function-based indexes
- Index read/write performance

## What I understood

- An index is a data structure that accelerates lookups by mapping values to
  rows.
- The database optimizer decides whether to use an index or perform a full scan
  based on estimated cost (e.g., cardinality).
- Low cardinality generally makes indexes less effective.
- High cardinality generally makes indexes more effective.
- Indexes are most useful when queries return a small subset of rows with many
  distinct values.
- Indexes are typically used for small range queries.
- Full table scans are often better for large range queries.
- A composite index is sorted by multiple columns.
- Leftmost prefix rule: a composite index is only usable starting from its
  leftmost column(s).
- Applying functions to indexed columns can prevent index usage.
- Function-based indexes can restore usability if the function is
  deterministic.
- Indexes slow down write operations (inserts/updates).

## What is still confusing

- The internal implementation details of composite indexes.
- How B-trees are implemented for composite indexes.

## Questions

- How does Oracle decide the cutoff point between using an index scan and a full table scan?

## Related concepts

- B-tree data structures
- ROWID (physical row addressing)
- Function determinism

## Resources used

- Guided explanations from ChatGPT
