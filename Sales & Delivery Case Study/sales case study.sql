create database sales;
use sales;

-- Question 1: Find the top 3 customers who have the maximum number of orders
select cust_id,(select customer_name from cust_dimen c where c.cust_id=m.cust_id) as c_name,count(distinct ord_id) 
from market_fact m group by 1,2 order by 3 desc limit 3;

-- Question 2: Create a new column DaysTakenForDelivery that contains the date difference between Order_Date and Ship_Date.
select distinct ord_id,datediff(str_to_date(ship_date,'%d-%c-%Y'),str_to_date(order_date,'%d-%c-%Y')) as DaysTakenForDelivery 
from orders_dimen o join shipping_dimen s using(order_id);

-- Question 3: Find the customer whose order took the maximum time to get shipped.
select c.cust_id,customer_name,datediff(str_to_date(ship_date,'%d-%c-%Y'),str_to_date(order_date,'%d-%c-%Y')) as DaysTakenForDelivery 
from orders_dimen o join shipping_dimen s using(order_id) join market_fact m using(ship_id) join cust_dimen c using(cust_id) order by 3 desc limit 1;

-- Question 4: Retrieve total sales made by each product from the data (use Windows function)
select distinct prod_id,round(sum(sales)over(partition by prod_id order by prod_id),2) as total_sales 
from market_fact m join prod_dimen p using(prod_id);

-- Question 5: Retrieve the total profit made from each product from the data (use Windows function)
select distinct prod_id,round(sum(profit)over(partition by prod_id order by prod_id),2) as total_profit 
from market_fact m join prod_dimen p using(prod_id);

-- Question 6: Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011

select*from
(select *,count(cust_id) over(partition by cust_id) other_months from 
(
select distinct cust_id, month(str_to_date(order_date, '%d-%m-%Y')) as month,
count(distinct ord_id) as jan  from market_fact inner join orders_dimen using(ord_id)
where  year(str_to_date(order_date, '%d-%m-%Y')) = 2011
group by 1,2) a
order by cust_id, month)
b where other_months=12;
