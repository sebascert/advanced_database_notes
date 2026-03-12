# 2026-03-05

## Topics Covered

- SQL analytic (window) functions
- The `OVER()` clause
- `PARTITION BY`
- `ORDER BY` within window functions
- Window frame clauses (`ROWS` / `RANGE`)
- Sliding window computations
- Ranking functions (`ROW_NUMBER`, `RANK`, `DENSE_RANK`)
- Filtering analytic function results through subqueries

## What I understood

- SQL analytic functions map functions over sets of rows.
- The `OVER()` clause defines the window used for the calculation.
- `PARTITION BY` splits the data into independent groups.
- `ORDER BY` defines the order used for ranking or running calculations.
- Window frames (`ROWS` / `RANGE`) define which rows around the current row are
  included.
- Ranking functions like `ROW_NUMBER`, `RANK`, and `DENSE_RANK` assign
  positions within a partition.
- To filter results based on window functions, a subquery is usually required.

# What is still confusing

## Questions

## Related concepts

- DENSE_RANK()
- ROW_NUMBER()
- SQL Aggregate Functions

## Resources used

- [freesql](https://freesql.com)
- [datalemur](https://datalemur.com)
- [geeksforgeeks rank and dense rank in sql server](https://www.geeksforgeeks.org/sql-server/rank-and-dense-rank-in-sql-server)
