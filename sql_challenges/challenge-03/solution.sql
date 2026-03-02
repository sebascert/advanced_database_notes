--EXCERCISE 10
-- 1
SELECT MAX(Years_employed) AS longest_time FROM employees;

--2
SELECT role, AVG(Years_employed) AS avg_time FROM employees GROUP BY role;

--3
SELECT building, SUM(years_employed) AS total_employee_years FROM employees
GROUP BY building;

--EXCERCISE 11
--1
SELECT COUNT(role) AS number_of_artists FROM employees WHERE role = "Artist";

--2
SELECT role, COUNT(role) AS number_of_artists FROM employees GROUP BY role;

--3
SELECT role, SUM(years_employed) FROM employees WHERE Role = "Engineer";

--FREESQL
--4
SELECT COUNT( DISTINCT shape) AS number_of_shapes, STDDEV( DISTINCT weight) AS
    distinct_weight_stddev FROM   bricks;

--6
SELECT shape, SUM(weight) AS shape_weight FROM bricks GROUP BY shape;

--8
SELECT shape, SUM( weight ) FROM bricks GROUP BY shape HAVING SUM( weight ) <
4;
