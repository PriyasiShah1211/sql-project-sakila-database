-- SUBQUERIES

-- Put relevant database to use
use sakila

-- 1. Find customers who live in the same city as store 1.Return: customer_name, city_name
select
	c.first_name + ' ' + c.last_name as Customer_Name
from customer c
inner join address a on a.address_id = c.address_id
inner join city ci on a.city_id = ci.city_id
where ci.city_id in
(
	select
		a2.city_id
	from store s
	inner join address a2 on a2.address_id = s.address_id
	where s.store_id = 1
)

-- 2. Find the customer(s) who made the highest total payment amount.Return: customer_name, payment_amount
select top 1
	c.first_name + ' ' + c.last_name as Customer_Name,
	sum(p.amount) as Payment_Amount
from customer c
inner join payment p on c.customer_id = p.customer_id
group by c.customer_id , c.first_name, c.last_name
order by Payment_Amount desc

-- 3. Find the customer(s) who made the highest payment amount.Return: customer_name, payment_amount
select top 1
	c.first_name + ' ' + c.last_name as Customer_Name,
	p.amount as Payment_Amount
from customer c
inner join payment p on c.customer_id = p.customer_id
where p.amount = (
	select MAX(amount)
	from payment )

-- 4. Find all staff members who work in the same store as “Mike Hillyer”. Return: staff_name, store_id
select
	s.store_id,
	s.first_name + ' ' + s.last_name as Staff_Name
from staff s
where s.store_id in
(	select
		store_id
	from staff
	where first_name = 'Mike' and last_name = 'Hillyer'
)

-- 5. List films that are shorter than all films in the ‘Comedy’ category.Return: film_title, length
select
	f.title as Film_Title,
	f.length as Length
from film f
where f.length < ALL (
	select
		f2.length
	from film f2
	inner join film_category fc on fc.film_id = f2.film_id
	inner join category c on c.category_id = fc.category_id
	where c.name = 'Comedy' )

-- 6. Find customers who have made more payments than the average number of payments per customer.Return: customer_name, payment_count
select 
	c.first_name + ' '  + c.last_name as Customer_Name,
	COUNT(p.payment_id) as payment_count
from customer c
inner join payment p on c.customer_id = p.customer_id
group by c.customer_id , c.first_name, c.last_name
having COUNT(p.payment_id) > (
	select AVG(payment_count)
	from ( 
		select
		 count(*) as payment_count
		from payment
		group by customer_id ) as sub
)
order by payment_count desc

-- 7.Find the country with the maximum number of customers.Return: country_name, customer_count
 select top 1
    co.country as country_name,
    COUNT(c.customer_id) as customer_count
from customer c
INNER JOIN address a on c.address_id = a.address_id
INNER JOIN city ci on a.city_id = ci.city_id
INNER JOIN country co on ci.country_id = co.country_id
group by co.country
order by COUNT(c.customer_id) DESC

-- 8. List customers who have rented every film in the ‘Action’ category.Return: customer_name
select
	c.first_name + ' ' + c.last_name as Customer_Name
from customer c
inner join rental r ON c.customer_id = r.customer_id
inner join inventory i ON r.inventory_id = i.inventory_id
inner join film_category fc ON i.film_id = fc.film_id
inner join category cat ON fc.category_id = cat.category_id
WHERE cat.name = 'Action'
group by c.customer_id, c.first_name, c.last_name
having COUNT(distinct i.film_id) = (
	select 
		COUNT(*)
	from film_category fc
	inner join category c on fc.category_id = c.category_id
	where c.name = 'Action'
)

-- 9. Find the top 3 customers (by total amount spent) in each country.Return: country_name, customer_name, total_amount, rank
SELECT
    country_name,
    customer_name,
    total_amount,
    customer_rank
FROM (
    SELECT 
        co.country AS country_name,
        c.first_name + ' ' + c.last_name AS customer_name,
        SUM(p.amount) AS total_amount,
        RANK() OVER (PARTITION BY co.country ORDER BY SUM(p.amount) DESC) AS customer_rank
    FROM customer c
    JOIN address a ON c.address_id = a.address_id
    JOIN city ci ON a.city_id = ci.city_id
    JOIN country co ON ci.country_id = co.country_id
    JOIN payment p ON c.customer_id = p.customer_id
    GROUP BY co.country, c.customer_id, c.first_name, c.last_name
) AS ranked_customers
WHERE customer_rank <= 3
ORDER BY country_name, customer_rank

-- VIEWS

-- 1. Create a view that shows all films along with their category name and language name. Columns: film_title, category_name, language_name
create view v_film_info as 
(select 
	f.title as Film_Title,
	c.name as Film_category,
	l.name as Film_Language
from film f
inner join film_category fc on fc.film_id = f.film_id
inner join category c on c.category_id = fc.category_id
inner join language l on l.language_id = f.language_id)

-- 2. Create a view that shows each customer’s total payments and total rentals.Columns: customer_name, total_payments, total_rentals
create view v_customer_summary as
(select 
	c.first_name + ' ' + c.last_name as Customer_Name,
	ISNULL(SUM(p.amount),0) as Total_Payment,
	ISNULL(COUNT(r.rental_id),0) as Total_Rentals
from customer c
left join payment p on p.customer_id = c.customer_id
left join rental r on r.customer_id = c.customer_id
group by c.customer_id , c.first_name , c.last_name)

-- 3. Create a view that shows the top 5 customers (by spending) per country.Columns: country_name, customer_name, total_amount, rank
CREATE VIEW vw_top5_customers_per_country AS
SELECT *
FROM (
    SELECT 
        co.country,
        c.first_name + ' ' + c.last_name AS customer_name,
        SUM(p.amount) AS total_amount,
        RANK() OVER (
            PARTITION BY co.country_id 
            ORDER BY SUM(p.amount) DESC
        ) AS rank
    FROM payment p
    INNER JOIN customer c 
        ON p.customer_id = c.customer_id
    INNER JOIN address a 
        ON c.address_id = a.address_id
    INNER JOIN city ci 
        ON a.city_id = ci.city_id
    INNER JOIN country co 
        ON ci.country_id = co.country_id
    GROUP BY co.country_id, co.country, c.first_name, c.last_name
) sub
WHERE sub.rank <= 5