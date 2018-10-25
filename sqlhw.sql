Use sakila;

-- 1a. Display the first and last names of all actors from the table `actor`.
select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
select concat (first_name, ',', last_name) as 'Actor Name' from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name from actor where first_name="Joe";

-- 2b. Find all actors whose last name contain the letters `GEN`:
select * from actor where last_name like '%gen%'; 

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
select * from actor where last_name like '%li%' order by last_name, first_name asc; 

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB`
alter table actor add column description blob; 

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
alter table  actor drop column description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(last_name) from actor group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(last_name) as 'count' from actor group by last_name having count >1; 

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
update actor 
set first_name= "Harpo"
where first_name= "Groucho" and last_name= "Williams"; 

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
update actor 
set first_name="Groucho"
where first_name= "Harpo" and last_name="Williams";

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
show create table address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
select staff.first_name, staff.last_name, address.address
from staff inner join address on staff.address_id= address.address_id; 

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.***

select staff.first_name, staff.last_name, sum(payment.amount) as total_amount
from staff inner join payment on payment.staff_id= staff.staff_id
where payment_date like '2005-08%'
group by staff.staff_id;


-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
select film.title, count(film_actor.actor_id) as NumberofActors from film_actor 
inner join film on film_actor.film_id= film.film_id 
group by film.title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?**
select * from inventory;
select * from film;

select count(film_id) as Copies from inventory 
where film_id in (select film_id from film where title='Hunchback Impossible');

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
select * from payment;
select*from customer;

select customer.first_name, customer.last_name, sum(payment.amount) as total 
from payment inner join customer on customer.customer_id=payment.customer_id 
group by payment.customer_id
order by customer.last_name asc; 

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
select title 
from film 
where (title like 'K%' or 'O%') and language_id= 1;

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select first_name as 'First Name', last_name as 'Last Name' 
from actor 
where actor_id in (
	select actor_id from film_actor where film_id in (
		select film_id from film where title= 'Alone Trip'));


-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select first_name, last_name, email from customer
join address using (address_id)
join city using (city_id)
join country using (country_id)
where country= "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select title as Title
from film f 
where f.film_id in (
select film_id from film_category fc 
where fc.category_id in (
select category_id from category c 
where c.name= "family")); 

-- 7e. Display the most frequently rented movies in descending order.
select title as Title, count(i.film_id) as 'Times Rented'
from inventory i 
join film f on f.film_id=i.film_id
group by i.film_id
order by count(i.film_id) desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select c.store_id as 'store ID', sum(amount) as 'Total Business($)'
from store s
join customer c on s.store_id = c.store_id
join payment p on p.customer_id=c.customer_id
group by c.store_id; 

-- 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id as 'store id', c.city as 'city', cn.country as 'country'
from store s 
join address a on s.address_id = a.address_id 
join city c on a.city_id = c.city_id
join country cn on c.country_id = cn.country_id; 

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select name as 'Genre', sum(amount) as 'Gross Revenue ($)'
from category c
join film_category fc on c.category_id = fc.category_id
join inventory i on fc.film_id = i.film_id
join rental r on i.inventory_id = r.inventory_id
join payment p on r.rental_id = p.rental_id
group by c.name
order by sum(amount) desc limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view top_five_genres as
	select name, sum(amount) as 'Gross Revenue ($)'
	from category c
	join film_category fc on c.category_id = fc.category_id
	join inventory i on fc.film_id = i.film_id
	join rental r on i.inventory_id = r.inventory_id
	join payment p on r.rental_id = p.rental_id
	group by c.name
	order by sum(amount) desc limit 5;
    
-- 8b. How would you display the view that you created in 8a?
select * from top_five_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
drop view top_five_genres;