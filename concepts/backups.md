# SQL BACKUPS

## My understanding

A database backup is the process of creating a copy of a database’s structure
and/or data so it can be restored. In Oracle, backups can include:

## Why it matters

Backups are important because systems can fail or need to be migrated.

## Example

```sql
SELECT DBMS_METADATA.GET_DDL('TABLE', 'BRICKS')
FROM DUAL;
```

```sql
BEGIN
  DBMS_METADATA.SET_TRANSFORM_PARAM(
    DBMS_METADATA.SESSION_TRANSFORM,
    'EMIT_SCHEMA',
    false
  );
END;
/
```
