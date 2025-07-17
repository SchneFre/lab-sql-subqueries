USE sakila;

-- Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.

SELECT 
	COUNT(*)
FROM 
	film as f
JOIN inventory as i
ON f.film_id = i.film_id
WHERE title = "Hunchback Impossible";

-- List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT
	*
FROM 
	film 
WHERE film.length >
(
	SELECT
		AVG(length) as avg_length
	FROM film as f
);
-- Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT
	*
FROM 
	actor as a
WHERE a.actor_id IN (
	SELECT 
		fa.actor_id
	FROM 
		film_actor as fa
	WHERE film_id = (
		SELECT 
			f.film_id
		FROM film as f
		WHERE f.title = "Alone Trip"
	)
);

-- Sales have been lagging among young families, and you want to target family movies for a promotion. 
-- Identify all movies categorized as family films.

SELECT
	*
FROM 
	film as f
WHERE f.film_id IN (
	SELECT 
		fc.film_id
	FROM 
		film_category as fc
	where fc.category_id IN (
		SELECT 
			cat.category_id
		FROM category as cat
		where cat.name = "Family"
		)
	);

-- Retrieve the name and email of customers from Canada using both subqueries and joins. 
-- To use joins, you will need to identify the relevant tables and their primary and foreign keys.
SELECT 
    c.first_name,
    c.last_name,
    c.email
FROM
	customer as c
where c.store_id IN (
	SELECT 
		store_id
	FROM 
		address as a
	join store
	ON store.address_id = a.address_id
	WHERE a.city_id in (
		SELECT 
			city_id
		FROM city
		WHERE country_id IN (
			SELECT
				country_id
			FROM
				country 
			Where country = "Canada"
		)
	)
);
-- Determine which films were starred by the most prolific actor in the Sakila database. 
-- A prolific actor is defined as the actor who has acted in the most number of films. 
-- First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.
WITH prolific_actor AS (
	SELECT
		a.actor_id
		-- count(film_id) as film_count
	FROM
		actor as a
	JOIN
		film_actor as fa
	ON fa.actor_id = a.actor_id
	GROUP BY a.actor_id
	ORDER BY count(film_id)  desc
	LIMIT 1
    )

SELECT
	*
FROM film
WHERE film.film_id in (
	SELECT 
		film_id
	FROM film_actor as fa
	JOIN 
		prolific_actor pa 
		ON fa.actor_id = pa.actor_id
    );

 -- Find the films rented by the most profitable customer in the Sakila database. 
 -- You can use the customer and payment tables to find the most profitable customer, i.e., 
 -- the customer who has made the largest sum of payments.   
WITH most_profitable_customer AS (
	SELECT
		customer_id,
		SUM(amount) as total_customer_amount
	FROM payment
	GROUP BY customer_id
	ORDER BY total_customer_amount desc
	LIMIT 1
)

SELECT
	*
FROM 
	film
WHERE film.film_id IN (
	SELECT 
		DISTINCT(i.film_id)
	FROM 
		inventory as i
	WHERE i.inventory_id IN (
		SELECT 
			r.inventory_id
		FROM rental as r
		JOIN most_profitable_customer as mpa
		ON mpa.customer_id = r.customer_id
		)
);

-- Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.
-- You can use subqueries to accomplish this.
SELECT 	
	customer_id as client_id,
	SUM(amount) as total_amount_spent
	FROM 
		payment
	GROUP by
		customer_id
	HAVING total_amount_spent > (
			SELECT
				AVG(total_per_customer) as avg_spent_per_customer
			FROM (
				SELECT 		
					SUM(amount) as total_per_customer
				FROM 
					payment
				GROUP by
					customer_id
			) as customer_totals
);



