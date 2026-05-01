-- Lesson 04: Class Exercises
-- Students: complete these step by step. Don’t skip the verification steps.

-- ============================================================
-- EXERCISE 1: Manual transaction (warm-up)
-- ============================================================
-- Transfer $50 from Charlie (3) to Alice (1) using BEGIN / COMMIT manually.
-- Check balances before and after committing.

-- Your SQL here:

SELECT * FROM accounts ORDER BY account_id;

UPDATE accounts
SET balance = balance - 50
WHERE account_id = 3;

UPDATE accounts
SET balance = balance + 50
WHERE account_id = 1;

SELECT * FROM accounts ORDER BY account_id;
COMMIT;
SELECT * FROM accounts ORDER BY account_id;


-- ============================================================
-- EXERCISE 2: Use ROLLBACK to undo changes
-- ============================================================
-- Attempt to transfer $10,000 from Bob (2) to Charlie (3).
-- Before committing, inspect balances. Does Bob have enough?
-- Use ROLLBACK to revert the changes and confirm balances are restored.

-- Your SQL here:

SELECT * FROM accounts ORDER BY account_id;

UPDATE accounts
SET balance = balance - 10000
WHERE account_id = 2;

UPDATE accounts
SET balance = balance + 10000
WHERE account_id = 3;

SELECT * FROM accounts ORDER BY account_id;

ROLLBACK;
SELECT * FROM accounts ORDER BY account_id;


-- ============================================================
-- EXERCISE 3: SAVEPOINT checkpoint
-- ============================================================
-- Steps:
-- 1. Add $25 to Alice’s balance
-- 2. Create a savepoint
-- 3. Subtract $25 from Charlie’s balance (mistake — should be Bob)
-- 4. Roll back to the savepoint
-- 5. Subtract $25 from Bob’s balance instead
-- 6. Commit the transaction

-- Your SQL here:

UPDATE accounts
SET balance = balance + 25
WHERE account_id = 1;

SAVEPOINT after_alice;

UPDATE accounts
SET balance = balance - 25
WHERE account_id = 3;

SELECT * FROM accounts ORDER BY account_id;

ROLLBACK TO after_alice;

UPDATE accounts
SET balance = balance - 25
WHERE account_id = 2;

COMMIT;
SELECT * FROM accounts ORDER BY account_id;


-- ============================================================
-- EXERCISE 4: Create a stored procedure
-- ============================================================
-- Define a procedure deposit_funds(p_account_id, p_amount)
-- It should:
-- 1. Ensure p_amount > 0 (raise an error otherwise)
-- 2. Add p_amount to the account balance
-- 3. COMMIT if successful
-- 4. ROLLBACK and re-raise any error
-- Test it using: EXEC deposit_funds(3, 75);

-- Your SQL here:

CREATE OR REPLACE PROCEDURE deposit_funds(
    p_account_id NUMBER,
    p_amount NUMBER
)
IS
BEGIN
    IF p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Amount must be greater than 0');
    END IF;

    UPDATE accounts
    SET balance = balance + p_amount
    WHERE account_id = p_account_id;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

EXEC deposit_funds(3, 75);


-- ============================================================
-- EXERCISE 5: Discussion
-- ============================================================
-- Answer in words (no SQL required):

-- Q1: You are designing a patient appointment system.
-- A booking involves:
--   a) Reserving the time slot
--   b) Creating the appointment record
--   c) Sending a confirmation notification
-- Which steps belong inside the transaction, and which should be outside? Why?
--
-- Inside the transaction: reserving the slot and creating the appointment (must be atomic).
-- Outside the transaction: sending the notification (failure here should not affect the transaction).

-- Q2: Your procedure ends with a COMMIT.
-- Another developer calls it inside a larger transaction.
-- What issue does this cause?
--
-- It prematurely commits part of the larger transaction, preventing a full rollback.

-- Q3: You have a function calculate_copay() and a procedure post_payment().
-- A colleague wants to use calculate_copay() in a SELECT statement.
-- Is that valid? What about post_payment()? Why?
--
-- calculate_copay() can be used in a SELECT because functions return values and avoid side effects.
-- post_payment() cannot, since procedures modify state and are not usable in SELECT queries.
