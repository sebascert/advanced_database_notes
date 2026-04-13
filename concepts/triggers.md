# SQL Triggers

## My understanding

A trigger in SQL is a type of stored procedure that executes automatically when
a specific event occurs in a database table. Unlike regular procedures, it is
not called explicitly; instead, it is activated by operations such as `INSERT`,
`UPDATE`, or `DELETE`.

In essence, a trigger behaves like a rule attached to a table: whenever a
defined change happens, the database performs a predefined action in response.

## Why it matters

Triggers are useful because they allow you to automate behavior directly within
the database. For example, they can be used to maintain audit logs, propagate
changes across related tables, or enforce certain constraints.

Since they run at the database level, they help reduce the need for additional
logic in the application layer and ensure consistency regardless of how the
database is accessed.

## Example

```sql
CREATE TRIGGER log_transaction
AFTER UPDATE ON accounts
FOR EACH ROW -- ensures the trigger runs once per affected row, not per query
BEGIN
    INSERT INTO transaction_log(account_id, old_balance, new_balance, changed_at)
    VALUES (OLD.id, OLD.balance, NEW.balance, NOW());
END;
```
