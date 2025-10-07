COMPREHENSIVE SQL PORTFOLIO – SAKILA DATABASE

1. About Me
Hi! I am Priyasi Shah, an aspiring SQL Developer / Data Analyst passionate about turning raw data into insights. This repository showcases my SQL practice project built using the Sakila sample database - a dataset 
designed to simulate a real-world DVD rental business.

- - - 

2. Database Used
Sakila Database – a sample MySQL database that models a DVD rental store. It includes entities like **films, actors, customers, rentals, payments, and staff**, making it ideal for exploring complex relationships, 
analytical queries, and business scenarios.

- - - 

3. About This Project
This project demonstrates both Foundational and Advanced SQL concepts using realistic and hypothetical scenarios derived from the Sakila database.  It showcases practical SQL applications - from data extraction and 
transformation to automation and performance optimization.

- - - 

4. Objectives
	1. Analyze rental, revenue, and customer trends
	2. Work with complex relationships using joins, subqueries, and CTEs
	3. Automate business logic through triggers and stored procedures
	4. Optimize query performance using indexing

- - - 

5. Repository Overview
| File Name | Description |
|------------|-------------|
| `01_Database_Schema_and_Data.sql` | Database creation, table definitions, data insertion, and key constraints setup. |
| `02_SQL_Queries_and_Joins.sql` | Core SQL operations - SELECT, WHERE, GROUP BY, HAVING, and multi-table joins. |
| `03_Subqueries_and_Views.sql` | Advanced SQL with subqueries (single, multi-row, correlated) and views. |
| `04_CTE_and_Window_Functions.sql` | Demonstrates CTEs, derived tables, and analytical/window functions. |
| `05_StoredProcedures_UDFs_Triggers_Indexing.sql` | Covers stored procedures, UDFs, triggers, and indexing for performance tuning. |
| `Sakila_ERD.png` | Entity Relationship Diagram highlighting relationships between tables. |
| `Screenshots/` | Sample query results and execution outputs. |

- - -

6. Sample Query - Customer Rental Insights
Goal - Identify the top 5 customers who spent the most on movie rentals in each city.
Concept/s used – Aggregation, Window Function, CTE

	```sql
WITH CustomerSpend AS (
    SELECT 
        c.customer_id,
        ci.city,
        SUM(p.amount) AS total_spent,
        RANK() OVER(PARTITION BY ci.city ORDER BY SUM(p.amount) DESC) AS rank_within_city
    FROM payment p
    JOIN customer c ON p.customer_id = c.customer_id
    JOIN address a ON c.address_id = a.address_id
    JOIN city ci ON a.city_id = ci.city_id
    GROUP BY c.customer_id, ci.city
)
SELECT * 
FROM CustomerSpend
WHERE rank_within_city <= 5;

- - 

7. Tools Used
	1. SQL Server Management Studio / MS SQL Server
	2. Git & GitHub (for version control)

- - -

8. Skills Demonstrated
	1. Query Optimization & Indexing
	2. Analytical SQL (aggregations, subqueries, window functions)
	3. Creating and Managing Views, Triggers, and UDFs
	4. Writing Maintainable SQL Code

9. Connect With Me
	1. LinkedIn: www.linkedin.com/in/priyasi-shah/
	2. Email: shahpriyasi1111@gmail.com
	3. GitHub: github.com/PriyasiShah1211

