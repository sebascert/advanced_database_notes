## SQL JOINs

- A `JOIN` combines rows from two or more tables based on a related column.
- Conceptually, a JOIN starts from a Cartesian product and then filters rows
  using the join condition (`ON` clause).

### Common JOIN Types

- `INNER JOIN`: Returns only rows with matching values in both tables.
- `LEFT JOIN`: Returns all rows from the left table and matching rows from the
  right table; non-matching right rows become `NULL`.
- `RIGHT JOIN`: Returns all rows from the right table and matching rows from
  the left table; non-matching left rows become `NULL`.
- `FULL JOIN`: Returns all rows from both tables; rows without matches on
  either side are filled with `NULL`.

### Why JOINs Matter

- They allow normalized databases (3NF) to be queried as if data were stored
  together.
- Proper JOIN usage avoids data duplication while enabling complex queries.
