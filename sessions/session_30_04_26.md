# 2026-04-30

## Topics covered

- Exporting object defs using DBMS_METADATA.GET_DDL.
- Using USER_DEPENDENCIES.
- Dependency order.
- Schema objects using USER_OBJECTS.

## What I understood

- Migrations require a specific recreation order because of DB object dependencies.
- Without DBA permissions it is still possible to perform schema backups using
  only SQL.
- DBMS_METADATA.GET_DDL can recreate the SQL definition of tables, indexes,
  sequences, procedures, triggers, and other objects.

## What is still confusing

## Questions

## Related concepts

- DBMS_METADATA
- USER_DEPENDENCIES
- Data Pump (expdp / impdp)

## Resources used

- [https://sqlbolt.com/](https://sqlbolt.com/)
