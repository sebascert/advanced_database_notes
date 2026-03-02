# SQL Aggregate Functions

SQL aggregate functions perform calculations over a set of rows and return
a single value. Instead of displaying each individual record,
they condense data into a meaningful a value that represents the dataset
as a whole.

## Use Case

Aggregate functions are essential for summarizing data derived from multiple
rows. They allow SQL to compute results that would otherwise require external
processing.

Common uses include:

- Calculating the total sales of a store
- Computing the average grade of a class
- Identifying the highest salary within a department

Without aggregate functions, these calculations would need to be performed
manually outside the database.

## GROUP BY

The `GROUP BY` clause is used when aggregate results are required **per
category** rather than as a single value for the entire table. It divides rows
into groups based on one or more columns, and aggregate functions are then
applied to each group independently.

```sql
SELECT course_id, AVG(grade) AS average_grade FROM Enrollments GROUP BY
course_id;
```

## Example

```sql
SELECT AVG(grade) AS average_grade FROM Students;
```

This query returns the overall average grade of all registered students.
