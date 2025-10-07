-- DERIVED TABLES

-- Put relevant database to use
use sakila

-- 1. Find the average film length per category, and then list all categories whose average length is greater than 120 minutes.
select
	x.[ Category Name],
	x.[Avg Film Length By Category]
from
	( select 
		c.name as ' Category Name' , 
		AVG(f.length) as 'Avg Film Length By Category'
	from film f
	inner join film_category fc on fc.film_id = f.film_id
	inner join category c on c.category_id = fc.category_id
	group by c.category_id , c.name ) as x
where [Avg Film Length By Category] > 120
order by [Avg Film Length By Category] desc

-- 2. Find the top 2 most rented films in each store. Return: store_id, film_title, rental_count, rank
SELECT 
    t.store_id,
    t.film_title,
    t.rental_count,
    t.rank
FROM (
    SELECT 
        i.store_id,
        f.title AS film_title,
        COUNT(r.rental_id) AS rental_count,
        RANK() OVER (PARTITION BY i.store_id ORDER BY COUNT(r.rental_id) DESC) AS rank
    FROM rental r
    INNER JOIN inventory i ON r.inventory_id = i.inventory_id
    INNER JOIN film f ON i.film_id = f.film_id
    GROUP BY i.store_id, f.title
) AS t
WHERE t.rank <= 2
ORDER BY t.store_id, t.rank

-- 3. Find actors who have acted in more films than the average number of films per actor.
SELECT 
    a.actor_id,
    CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
    sub.film_count
FROM (
    SELECT 
        fa.actor_id,
        COUNT(fa.film_id) AS film_count
    FROM film_actor fa
    GROUP BY fa.actor_id
) AS sub
INNER JOIN actor a ON sub.actor_id = a.actor_id
WHERE sub.film_count > (
    SELECT AVG(film_count)
    FROM (
        SELECT 
			actor_id, 
			COUNT(film_id) AS film_count
        FROM film_actor
        GROUP BY actor_id
    ) AS avg_sub
ORDER BY sub.film_count DESC

-- COMMON TABLE EXPRESSIONS

-- 1. Find the total number of films released each year, and then return only those years with more than 50 films.

with x as 
( select
		film.release_year as Release_Year,
		count(film.title) as ' Films released each year' 
from film
group by film.release_year )

select
	x.Release_Year,
	x.[ Films released each year]
from x
where x.[ Films released each year] > 50

-- 2. Find the top 5 actors with the highest average film length across all films they acted in.
with x as 
( SELECT 
        a.actor_id,
        CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
        AVG(f.length) AS avg_film_length
  FROM actor a
  INNER JOIN film_actor fa ON a.actor_id = fa.actor_id
  INNER JOIN film f ON fa.film_id = f.film_id
  GROUP BY a.actor_id, a.first_name, a.last_name )

SELECT TOP 5
    actor_name,
    avg_film_length
FROM x
ORDER BY avg_film_length DESC

-- 3. Find the cities where the total revenue (sum of payments) is higher than the average city revenue.
with x as 
( select
	ci.city_id,
	ci.city as 'City',
	SUM(p.amount) as 'Total Revenue'
from payment p
inner join customer c on c.customer_id = p.customer_id
inner join address a on a.address_id = c.address_id
inner join city ci on ci.city_id = a.city_id
group by ci.city_id , ci.city )

select
	x.City,
	x.[Total Revenue]
from x
where x.[Total Revenue] >
	(select
		AVG(x.[Total Revenue])
	from x )
order by x.[Total Revenue] desc

-- 4. List films where the film title length is longer than the average film title length in its category. Return: film_title, category_name, title_length
with x as 
(
select
	f.title as Film_Title,
	c.name as Category_Name,
	LEN(f.title) as Title_Length,
	AVG(LEN(f.title)) over (partition by c.category_id) as 'Avg_title_length'
from film f
inner join film_category fc on fc.film_id = f.film_id
inner join category c on c.category_id = fc.category_id
)

select
	Film_Title,
	Category_Name,
	Title_Length,
	Avg_title_length
from x
where Title_Length > Avg_title_length
order by Category_Name , Film_Title

-- 5. For each language, find the average number of actors per film, but only include films in categories with more than 10 films.
-- Return: language_name, avg_actors_per_film.

with 
category_filter as 
(
	select fc.category_id
	from film_category fc
	group by fc.category_id
	having fc.category_id > 10
),
film_actor_count as 
(
select
	f.film_id,
	f.language_id,
	COUNT(fa.actor_id) as Actor_Count
from film f
inner join film_category fc on fc.film_id = f.film_id
inner join category_filter cf on cf.category_id = fc.category_id
inner join film_actor fa on fa.film_id = f.film_id
group by f.film_id , f.language_id
)
select
	l.name as Language_Name,
	AVG(actor_count * 1 ) as Avg_actors_per_film
from film_actor_count fac
inner join language l on l.language_id = fac.language_id
group by l.name
order by Avg_actors_per_film desc

-- WINDOWS FUNCTION (AGGREGTAION)

-- 1. For each film, show its title, length, and the average film length of all films in the same language.
-- Return: film_title, language_name, film_length, avg_length_per_language
select
	f.title as 'Film Title',
	f.length as 'Film Length' ,
	l.name as 'Language Name',
	AVG(f.length) OVER (partition by l.language_id) as ' Avg length per language'
from film f 
inner join language l on l.language_id = f.language_id
order by l.name , f.title

-- 2. For each customer, show their total payments and the average payment amount across all customers in the same city.
-- Return: customer_name, city_name, total_payment, avg_payment_in_city

select
	c.first_name + ' ' + c.last_name as 'Customer Name' ,
	ci.city as City ,
	SUM(p.amount) as 'Total Payment',
	AVG(SUM(p.amount)) OVER (partition by ci.city_id) as 'Avg Payment in City'
from customer c 
inner join payment p on c.customer_id = p.customer_id
inner join address a on a.address_id = c.address_id
inner join city ci on ci.city_id = a.city_id
group by c.customer_id , c.first_name , c.last_name, ci.city_id , ci.city
order by ci.city , [Total Payment] desc

-- WINDOWS FUNCTION (RANKING)
-- 1. Rank films within each category by their rental rate, with the highest rental rate ranked first.Return: category_name, film_title, rental_rate, rank
select
	c.name as 'Category Name' , 
	f.title as 'Film Title' , 
	f.rental_rate as 'Rental Rate',
	RANK() OVER (partition by c.category_id order by f.rental_rate desc) as 'Rank'
from film f
inner join film_category fc on fc.film_id = f.film_id
inner join category c on c.category_id = fc.category_id
order by c.name , Rank

-- 2. Find the top 3 customers by payment amount in each country, including their rank.Return: country_name, customer_name, total_payment, rank
select
	[Country Name],
	[Customer Name],
	[Total Payment],
	Rank
from
(select
	co.country as 'Country Name',
	c.first_name + ' ' + c.last_name as 'Customer Name' , 
	SUM(p.amount) as 'Total Payment' , 
	RANK() over (partition by co.country_id order by SUM(p.amount) desc) as 'Rank'
from customer c
inner join payment p on p.customer_id = c.customer_id
inner join address a on a.address_id = c.address_id
inner join city ci on ci.city_id = a.city_id
inner join country co on co.country_id = ci.country_id
group by co.country_id , co.country , c.customer_id , c.first_name , c.last_name) as x
where x.Rank <= 3
order by x.[Country Name] , x.Rank

-- 3.Rank categories by average film length, and show the top 3 categories, including their rank.Return: rank, category_name, avg_length
select top 3
	RANK() over (order by AVG(f.length) desc) as Rank ,
	c.name as Category_Name,
	AVG(f.length) as Avg_Length
from film f
inner join film_category fc on f.film_id = fc.film_id
inner join category c on c.category_id = fc.category_id