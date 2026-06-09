# ORM

## My understanding

An ORM, Object-Relational Mapping, is a library/framework which allows us to
interact with the database via OOP Classes as if they were tables. It works by
converting classes operations and schemas to SQL statements with a translation
engine.

## Why it matters

ORMs are useful because they reduce the amount of SQL code developers need to
write and maintain. They also make applications easier to develop by allowing
programmers to work with familiar programming concepts.

## Example

Instead of writing this:

```sql
SELECT * FROM users
WHERE id = 1;
```

We can do:

```sql
user = User.get(id=1)
print(user.name)
```
