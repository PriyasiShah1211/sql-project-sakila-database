-- BASIC LEVEL QUESTION BANK(focus: SELECT, WHERE, ORDER BY)

-- Put relevant database to use
use sakila

-- 1. Find all films that have a rating of ‘PG’ and running time less than 120 minutes. Return: title, rating, length
select
	title,
	rating,
	length
from film
where rating = 'PG'  and length < 120

-- 2. List all actors whose last name begins with "S". Return: first_name, last_name
select
	first_name,
	last_name
from actor
where first_name like 'S%'

-- 3. Show the names of all customers who live in ‘Canada’.Return: first_name, last_name, email, country
select
	first_name,
	last_name,
	email,
	country
from customer cu
inner join address a on a.address_id = cu.address_id
inner join city c on c.city_id = a.city_id
inner join country co on co.country_id = c.country_id
where co.country = 'Canada'

-- INTERMEDIATE LEVEL QUESTION BANK (focus: JOINS, GROUP BY, AGGREGATES)

-- 1. Find the number of films in each category (genre).Return: category_name, film_count
select
	c.name,
	COUNT(f.film_id) as 'Film_Count' 
from film f
inner join film_category fc on fc.film_id = f.film_id
inner join category c on c.category_id = fc.category_id
group by c.name

-- 2. List all films along with their language name.Return: film.title, language.name
select
	f.title,
	l.name
from film f
inner join language l on f.language_id = l.language_id
order by f.title

-- 3. Find the top 5 cities with the most customers.Return: city, number_of_customers
select top 5
	ci.city,
	COUNT(c.customer_id) as 'Number_Of_Customers'
from customer c
inner join address a on c.address_id = a.address_id
inner join city ci on ci.city_id = a.city_id
inner join country co on ci.country_id = co.country_id
group by ci.city
order by Number_Of_Customers desc

-- ADVANCED LEVEL QUESTION BANK (focus: Nested queries, HAVING, multi-table joins)

-- 1. Find actors who have appeared in more than 10 films.Return: actor_name, film_count
select
	a.first_name,
	COUNT(fa.film_id) as 'Film_Count'
from actor a
inner join film_actor fa on fa.actor_id = a.actor_id
group by a.actor_id , a.first_name , a.last_name
having COUNT(fa.film_id) > 10
order by Film_Count desc

-- 2. Find the categories that have an average film length greater than 120 minutes.Return: category_name, average_length
select
	c.name as 'Category_Name' , 
	AVG(f.length) as Avg_Length
from film f 
inner join film_category fc on fc.film_id = f.film_id
inner join category c on c.category_id = fc.category_id
group by c.name
having AVG(f.length) > 120
order by Avg_Length desc

-- 2. List the film(s) that feature both NICK WAHLBERG and ED CHASE.Return: film.title
select
	f.title
from film f 
inner join film_actor fa on fa.film_id = f.film_id
inner join actor a on a.actor_id = fa.actor_id
where a.first_name in ('NICK' , 'ED') and a.last_name in ('WAHLBERG' , 'CHASE')
group by f.film_id , f.title
having COUNT(distinct a.actor_id) = 2

-- 3. List the categories where the average film length in French is greater than 130 minutes. Return: category_name, avg_length
select
	c.name,
	AVG(f.length) as 'Avg_Length'
from film f
inner join film_category fc on fc.film_id = f.film_id
inner join category c on fc.category_id = c.category_id
inner join language l on l.language_id = f.language_id
where l.name = 'French'
group by c.name
having AVG(f.length) > 130

-- 4. Find the top 5 actors who have acted in the most distinct categories of films.Return: actor_name, category_count
select top 5
	a.first_name,
	a.last_name,
	COUNT(distinct c.category_id) as 'Category_Count' 
from actor a
inner join film_actor fa on fa.actor_id= a.actor_id
inner join film f on f.film_id = fa.film_id
inner join film_category fc on fc.film_id = f.film_id
inner join category c on c.category_id = fc.category_id
group by a.actor_id , a.first_name , a.last_name
order by Category_Count desc

-- 5. Find all films that feature both “CHRISTIAN GABLE” and “JENNIFER DAVIS”, but do not feature “TOM HARDY”.Return: film_title
select f.title as film_title
from film as f
INNER JOIN film_actor as fa on f.film_id = fa.film_id
INNER JOIN actor as a on fa.actor_id = a.actor_id
GROUP BY f.film_id, f.title
HAVING 
    SUM(CASE WHEN a.first_name = 'CHRISTIAN' AND a.last_name = 'GABLE' THEN 1 ELSE 0 END) > 0
    AND SUM(CASE WHEN a.first_name = 'JENNIFER' AND a.last_name = 'DAVIS' THEN 1 ELSE 0 END) > 0
    AND SUM(CASE WHEN a.first_name = 'TOM' AND a.last_name = 'HARDY' THEN 1 ELSE 0 END) = 0
ORDER BY f.title

-- 6. Find all films whose title contains more than 3 words and have actors whose first name starts with ‘A’ or ‘J’.Return: film_title, actor_name
select
	f.title,
	CONCAT(a.first_name, ' ', a.last_name) AS actor_name
from film f
inner join film_actor fa on fa.film_id = f.film_id
inner join actor a on a.actor_id = fa.actor_id
where
	(LEN(f.title) - LEN(REPLACE(f.title, ' ', '')) + 1 ) > 3
	and (a.first_name like 'A%' or a.first_name like 'J%')