--6
SELECT m.Title,
       b.Domestic_sales,
       b.International_sales
FROM movies m
JOIN Boxoffice b
    ON m.id = b.movie_id;


SELECT m.Title,
       b.Domestic_sales,
       b.International_sales
FROM movies m
JOIN Boxoffice b
    ON m.id = b.movie_id
WHERE b.International_sales > b.Domestic_sales;


SELECT m.Title,
       b.Rating
FROM movies m
JOIN Boxoffice b
    ON m.id = b.movie_id
ORDER BY b.Rating DESC


--7
SELECT DISTINCT b.Building_name
FROM buildings b
JOIN Employees e
    ON e.Building = b.Building_name;


SELECT *
FROM buildings;


SELECT DISTINCT b.Building_name,
                e.Role
FROM buildings b
LEFT JOIN Employees e
    ON e.Building = b.Building_name;


--DataLemur
SELECT a.page_id
FROM pages a
LEFT JOIN page_likes b
ON a.page_id = b.page_id
WHERE b.user_id IS NULL
ORDER BY page_id ASC;
