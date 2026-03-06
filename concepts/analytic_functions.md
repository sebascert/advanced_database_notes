# Analytic Functions

## My understanding

Analytic functions map functions to a set of rows, computing some value for
each one.

## Why it matters

They are useful for solving more complex problems using sql, reducing query
complexity and exterenal processing.

## Example

```sql
SELECT
  order_id,
  customer_id,
  amount,
  AVG(amount) OVER (PARTITION BY customer_id) AS avg_customer_order
FROM Orders;
```

This calculates the **average order amount per customer**, while still
displaying every order.

### PARTITION BY

```sql
SELECT
  product_id,
  category,
  sales,
  RANK() OVER (
      PARTITION BY category
      ORDER BY sales DESC
  ) AS category_rank
FROM Products;
```

This ranks products **within each category** based on their sales.

### ORDER BY

```sql
SELECT
  order_date,
  amount,
  SUM(amount) OVER (
      ORDER BY order_date
  ) AS cumulative_sales
FROM Orders;
```

This computes the **running total of sales over time**.

### Windowing Clause

```sql
SELECT
  order_date,
  amount,
  SUM(amount) OVER (
      ORDER BY order_date
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS cumulative_sales
FROM Orders;
```

This calculates a **running total of all sales up to each date**.

### Sliding Window

```sql
SELECT
  order_date,
  amount,
  AVG(amount) OVER (
      ORDER BY order_date
      ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
  ) AS moving_avg_sales
FROM Orders;
```

This computes the **average sales of the last 4 orders** (current row + 3
previous rows).

### Filtering in Analytic Functions

```sql
SELECT *
FROM (
    SELECT
      product_id,
      sales,
      ROW_NUMBER() OVER (ORDER BY sales DESC) AS sales_rank
    FROM Products
) t
WHERE sales_rank <= 5;
```

This returns the top 5 products with the highest sales.
