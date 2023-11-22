# Date created and Last ran : 11-22-2023 
# Queries written in MySQL Workbench 8.0 to solve the Interview question by Ankit Bansal on 11/22

CREATE DATABASE Ankit_challenges;
USE Ankit_challenges;

/*problem 1:*/

CREATE TABLE flights 
(
 cid VARCHAR(512),
 fid VARCHAR(512),
 origin VARCHAR(512),
 Destination VARCHAR(512)
);
SELECT * FROM flights;
INSERT INTO flights (cid, fid, origin, Destination) VALUES ('1', 'f1', 'Del', 'Hyd');
INSERT INTO flights (cid, fid, origin, Destination) VALUES ('1', 'f2', 'Hyd', 'Blr');
INSERT INTO flights (cid, fid, origin, Destination) VALUES ('2', 'f3', 'Mum', 'Agra');
INSERT INTO flights (cid, fid, origin, Destination) VALUES ('2', 'f4', 'Agra', 'Kol');

/* Creating tables for Problem 2 */

CREATE TABLE sales 
(
 order_date date,
 customer VARCHAR(512),
 qty INT
);

INSERT INTO sales (order_date, customer, qty) VALUES ('2021-01-01', 'C1', '20');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-01-01', 'C2', '30');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-02-01', 'C1', '10');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-02-01', 'C3', '15');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-03-01', 'C5', '19');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-03-01', 'C4', '10');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-04-01', 'C3', '13');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-04-01', 'C5', '15');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-04-01', 'C6', '10');
SELECT * FROM sales;

/* Query to Solve Problem 1*/
/* Easy and lazy approach which assumes each flight in the table will have only one interim stop before the final destination*/
WITH RankedFlights AS (
    SELECT
        cid,
        origin,
        Destination,
        DENSE_RANK() OVER (PARTITION BY cid ORDER BY fid) AS rnk
    FROM flights
)
SELECT
    cid,
    origin,
    Destination
FROM RankedFlights
WHERE rnk = 2;

/* Problem 1 - Comprehensive approach which accounts for multiple stop flights */
WITH RankedFlights AS (
    SELECT
        cid,
        origin,
        Destination,
        DENSE_RANK() OVER (PARTITION BY cid ORDER BY fid) AS rnk
    FROM flights
)
SELECT
    cid,
    origin,
    Destination
FROM RankedFlights
WHERE rnk = (SELECT MAX(rnk) FROM RankedFlights AS RF2 WHERE RF2.cid = RankedFlights.cid);

/* Problem 2- Find the Count of new customers */
SELECT
    DATE_FORMAT(order_date, '%b-%y') AS Month,
    COUNT(DISTINCT customer) AS new_customers
FROM
    sales s1
WHERE
    NOT EXISTS (
        SELECT 1
        FROM sales s2
        WHERE
            s2.customer = s1.customer
            AND s2.order_date < s1.order_date
    )
GROUP BY order_date;

/* With proper comments for clarity*/
-- Select the formatted order date as Month and count the distinct customers as new_customers
SELECT
    DATE_FORMAT(order_date, '%b-%y') AS Month,
    COUNT(DISTINCT customer) AS new_customers
FROM
    sales s1
WHERE
    -- Exclude customers who shopped in any preceding month
    NOT EXISTS (
        SELECT 1
        FROM sales s2
        WHERE
            s2.customer = s1.customer
            -- Check if the order date of the previous purchase is before the current order date
            AND s2.order_date < s1.order_date
    )
-- Group the results by year and month
GROUP BY order_date;
   

