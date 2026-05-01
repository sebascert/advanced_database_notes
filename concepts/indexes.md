# INDEXES

## My understanding

An index is a data structure which allows the database engine to optimize
queries from linear scanning to more clever techniques. Some of the data
structures used hashmaps or trees.

## Why it matters

Indexes provide means to scale databases, allowing them to perform queries much
faster at the cost of memory and overhead computations.

## Example

```SQL
CREATE INDEX idx_patient_id
ON patient_visits(patient_id);
SELECT *
FROM patient_visits
WHERE patient_id = 5432;
```
