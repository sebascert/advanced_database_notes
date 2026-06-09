# Aggregation

## My understanding

SQL aggregations are functions that process multiple rows of data and return a
single summarized result, making them useful for reporting and analysis. Common
aggregation functions include COUNT() to count rows, SUM() to calculate totals,
AVG() to compute averages, MIN() to find the smallest value, and MAX() to find
the largest value. Aggregations are often combined with the GROUP BY clause to
produce summaries for each category or group, such as calculating the total
sales per region or the number of tasks assigned to each employee. They can
also be filtered using HAVING, which applies conditions to aggregated results
after grouping has been performed.

## Why it matters

It allows us to perform more complex queries, and perform computations in the
database.

## Example

This is an example using "MAX"

```sql
SELECT max(years_employed) FROM employees;
```
