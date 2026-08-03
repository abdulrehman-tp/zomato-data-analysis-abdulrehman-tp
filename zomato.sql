create database zomato_project;
use zometo_project;

create table customer(
customer_id	varchar(50) primary key,
customer_name varchar(50),
city varchar(50),
sing_up_date date,	
acquisition_channel varchar(50)
);

create table restaurant(
restaurant_id  varchar(50) primary key,
restaurant_name	varchar(50),
cuisine_type varchar(50),
city varchar(50),
avg_rating float
);
create table orders(
order_id varchar(50) primary key,
customer_id	varchar(50),
restaurant_id varchar(50),
order_date	date,
order_amount float,
discount_amount	float,
discount_percentage	float,
delivery_fee int,
payment_mode varchar(50),
order_status varchar(50)
);

alter table orders
modify column order_amount decimal(10,2);

select * from orders;
select * from customer;
select * from restaurant;
select count(*) from orders;


-- 1. What is the total revenue (order_amount) generated month-over-month?

select date_format(order_date, "%Y-%m") as order_month, sum(order_amount) as Total_revenue from orders
where order_status = "delivered"
group by date_format(order_date, "%Y-%m")
order by order_month;



-- 2. What is the average order value (AOV) overall, and how does it vary by city?

-- AOV by Restaurant City:

select r.city as City , round(avg(order_amount),2) as Avg_order_value
from orders o join restaurant r 
on r.restaurant_id = o.restaurant_id
where order_status = "delivered"
group by r.city
order by Avg_order_value  desc;

-- AOV by Customers City:

select c.city as City, round(avg(order_amount),2) as Avg_order_value
from orders o join customer c 
on o.customer_id = c.customer_id 
where order_status = "delivered"
group by c.city
order by Avg_order_value desc;



-- 3. What is the trend in number of orders placed per week.

select year(order_date) as order_year,
	   week(order_date) as order_week,
		count(order_id) as total_order
from orders
where order_status = "Delivered"
group by year(order_date),  week(order_date)
order by order_year , order_week;



-- 4. Which payment mode contributes the highest revenue and highest order count?

select payment_mode as Payment_mode, 
		count(order_id) as total_order,
		sum(order_amount) as total_revenue
from orders
where order_status = 'Delivered'
group by payment_mode
order by total_revenue desc;



-- 5. Who are the top 10 customers by total spend?

select customer_name as Customer_name,
	   round(sum(order_amount),2) as total_spend
from customer c join orders o
on c.customer_id = o.customer_id
where order_status = 'Delivered'
group by customer_name
order by total_spend desc
limit 10 ;


-- 6. Which restaurants have an avg_rating above 4.5, and what's their total order count?

SELECT 
    r.restaurant_name, 
    r.avg_rating, 
    COUNT(o.order_id) AS total_orders
FROM orders o
JOIN restaurant r ON o.restaurant_id = r.restaurant_id
WHERE r.avg_rating > 4.5
GROUP BY r.restaurant_id, r.restaurant_name, r.avg_rating
ORDER BY total_orders DESC;

-- 7. Find customers who placed orders but whose city is different from the restaurants city.

SELECT 
    c.customer_name, 
    c.city AS customer_city, 
    r.restaurant_name, 
    r.city AS restaurant_city
FROM orders o JOIN customer c 
ON o.customer_id = c.customer_id JOIN restaurant r 
ON o.restaurant_id = r.restaurant_id
WHERE c.city != r.city;

-- 8. For each city, show the number of customers vs number of restaurants (side by side comparison).

SELECT 
    c.city,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    (SELECT COUNT(*) FROM restaurant r WHERE r.city = c.city) AS total_restaurants
FROM customer c
GROUP BY c.city
ORDER BY total_customers DESC;


-- 9. What % of orders are "same city" (customer and restaurant in the same city) vs "cross city"?

SELECT 
    CASE 
        WHEN c.city = r.city THEN 'Same City'
        ELSE 'Cross City'
    END AS order_type,
    COUNT(o.order_id) AS total_orders
FROM orders o JOIN customer c 
ON o.customer_id = c.customer_id
JOIN restaurant r 
ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY 
    CASE 
        WHEN c.city = r.city THEN 'Same City'
        ELSE 'Cross City'
    END;


-- 10.For each customer city, which cuisine_type generates the highest revenue?

SELECT 
    c.city AS customer_city,
    r.cuisine_type,
    SUM(o.order_amount) AS total_revenue
FROM orders o JOIN customer c 
ON  o.customer_id = c.customer_id JOIN restaurant r 
ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY c.city, r.cuisine_type
ORDER BY c.city, total_revenue DESC;





