# 2026-04-23

## Topics covered

- Database transactions
- COMMIT, ROLLBACK, and SAVEPOINT
- Error handling using EXCEPTION
- Differences between procedures and functions, especially in transactional contexts

## What I understood

- A transaction is a set of operations that must be treated as a single unit
  (either all succeed or none are applied).
- COMMIT finalizes and persists changes in the database.
- ROLLBACK reverts all changes made within the current transaction.
- SAVEPOINT allows rolling back to a specific point instead of undoing the
  entire transaction.
- Transactions guarantee atomicity, ensuring that incomplete changes are not
  left in the database.
- Procedures are generally used for operations that modify data (transactional
  work), while functions are intended to return values and typically avoid side
  effects.

## What is still confusing

## Questions

## Related concepts

- Error handling
- Functions vs procedures

## Resources used

- [https://www.geeksforgeeks.org/computer-science-fundamentals/difference-between-function-and-procedure/](https://www.geeksforgeeks.org/computer-science-fundamentals/difference-between-function-and-procedure/)
