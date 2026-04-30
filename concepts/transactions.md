# TRANSACTIONS

## My understanding

A trigger in SQL is a type of stored procedure that runs automatically when a
specific event happens on a table, such as INSERT, UPDATE, or DELETE. It is
bound to a table and responds to changes without being explicitly invoked.
Triggers can reference both the previous (old) and current (new) values of a
row during modifications.

## Why it matters

Triggers are useful because they enable the database to enforce rules and
automate behavior at the data level. Since they execute within the database,
they help maintain consistency even when multiple applications access or modify
the same data.

## Example

```SQL
CREATE OR REPLACE TRIGGER log_transaction
AFTER UPDATE ON accounts
FOR EACH ROW
BEGIN
    INSERT INTO transaction_log(
        account_id,
        old_balance,
        new_balance,
        changed_at
    )
    VALUES (
        :OLD.account_id,
        :OLD.balance,
        :NEW.balance,
        SYSDATE
    );
END;
/
```
