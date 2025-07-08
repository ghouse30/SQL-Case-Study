/*

-----------------------------------------------------------------------------------------------------------------------------------
													    Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

The provided document is a guide for the project. Follow the instructions and take the necessary steps to finish
the project in the SQL file			

-----------------------------------------------------------------------------------------------------------------------------------
                                                         Queries
use new_wheels;                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
use new_wheels;   
select*from customer_t;
select*from shipper_t;
select*from product_t;
select*from order_t;

/*-- QUESTIONS RELATED TO CUSTOMERS
     [Q1] What is the distribution of customers across states?
     Hint: For each state, count the number of customers.*/
select state,count(customer_id)as customer_count from customer_t group by state;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.

Hint: Use a common table expression and in that CTE, assign numbers to the different customer ratings. 
      Now average the feedback for each quarter. 

Note: For reference, refer to question number 4. Week-2: mls_week-2_gl-beats_solution-1.sql. 
      You'll get an overview of how to use common table expressions from this question.*/
select quarter_number, avg(case when customer_feedback like 'Very Bad' then 1
								when customer_feedback like 'Bad' then 2
								when customer_feedback like 'Okay' then 3
								when customer_feedback like 'Good' then 4
								when customer_feedback like 'Very Good' then 5 end) as rating from order_t group by quarter_number order by quarter_number;
                                
                                #or using common table expression CTE Method
with ratings_cte as (select quarter_number,case when customer_feedback like 'Very Bad' then 1
								when customer_feedback like 'Bad' then 2
								when customer_feedback like 'Okay' then 3
								when customer_feedback like 'Good' then 4
								when customer_feedback like 'Very Good' then 5 end as rating from order_t)
select quarter_number, avg(rating) from ratings_cte group by quarter_number order by quarter_number;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q3] Are customers getting more dissatisfied over time?

Hint: Need the percentage of different types of customer feedback in each quarter. Use a common table expression and
	  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
	  Now use that common table expression to find out the percentage of different types of customer feedback in each quarter.
      Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback.
      
Note: For reference, refer to question number 4. Week-2: mls_week-2_gl-beats_solution-1.sql. 
      You'll get an overview of how to use common table expressions from this question.*/
with feedback_Count as (select quarter_number,customer_feedback, count(order_id) as feedbackcount
						from order_t group by quarter_number,customer_feedback ),
	 total_feedback as (select quarter_number, count(order_id) as totalfeedback
					   from order_t group by quarter_number )
select quarter_number,customer_feedback,feedbackcount,totalfeedback, (feedbackcount*100/totalfeedback) as percentage
		from feedback_count join total_feedback using (quarter_number) 
        group by quarter_number,customer_feedback order by quarter_number,customer_feedback;


-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q4] Which are the top 5 vehicle makers preferred by the customer.

Hint: For each vehicle make what is the count of the customers.*/
select vehicle_maker, count(order_id) as TotalCustomer from product_t join order_t using(product_id) 
		group by vehicle_maker order by TotalCustomer desc limit 5;


-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q5] What is the most preferred vehicle make in each state?

Hint: Use the window function RANK() to rank based on the count of customers for each state and vehicle maker. 
After ranking, take the vehicle maker whose rank is 1.*/

/*select state,vehicle_maker,count(*) as CustomerCount, rank() over(partition by state order by count(*) desc)as ranking
		from product_t p join order_t o using(product_id) 
        join customer_t c using(customer_id)
		group by state,vehicle_maker order by ranking asc;*/
        
	##above is not used
with ranking_t as (select state,vehicle_maker,count(*) as CustomerCount, rank() over(partition by state order by count(*) desc)as ranks
				from product_t p join order_t o using(product_id) 
				join customer_t c using(customer_id)
				group by state,vehicle_maker )
select state,vehicle_maker,	CustomerCount,ranks from ranking_t where ranks=1;

-- ---------------------------------------------------------------------------------------------------------------------------------

/*QUESTIONS RELATED TO REVENUE and ORDERS 

-- [Q6] What is the trend of number of orders by quarters?

Hint: Count the number of orders for each quarter.*/
select quarter_number, count(order_id) from order_t group by quarter_number order by quarter_number;


-- ---------------------------------------------------------------------------------------------------------------------------------
#for revenue calculaion use this sum((quantity*vehicle_price)-(quantity*vehicle_price*discount))
						#or this sum(quantity * (vehicle_price * (1 - discount)))
/* [Q7] What is the quarter over quarter % change in revenue? 

Hint: Quarter over Quarter percentage change in revenue means what is the change in revenue from the subsequent quarter to the previous quarter in percentage.
      To calculate you need to use the common table expression to find out the sum of revenue for each quarter.
      Then use that CTE along with the LAG function to calculate the QoQ percentage change in revenue.*/

with quarterly_revenue as (select quarter_number,
					sum((quantity*vehicle_price)-(quantity*vehicle_price*discount))as Totalrevenue,
					lag(sum((quantity*vehicle_price)-(quantity*vehicle_price*discount))) over (order by quarter_number) as previous_quarter_revenue
					from order_t group by quarter_number)
select quarter_number,Totalrevenue,previous_quarter_revenue,
(Totalrevenue - previous_quarter_revenue) / previous_quarter_revenue * 100 as qoq_percentage_change from quarterly_revenue;

#or

WITH quarterly_revenue AS (
    SELECT
        quarter_number,
        SUM(quantity * (vehicle_price * (1 - discount))) AS total_revenue
    FROM
        order_t
    GROUP BY
        quarter_number
),
revenue_change AS (
    SELECT
        quarter_number,
        total_revenue,
        LAG(total_revenue) OVER (ORDER BY quarter_number) AS previous_quarter_revenue
    FROM
        quarterly_revenue
)
SELECT
    quarter_number,
    total_revenue,
    previous_quarter_revenue,
    CASE
        WHEN previous_quarter_revenue IS NULL THEN NULL
        ELSE (total_revenue - previous_quarter_revenue) / previous_quarter_revenue * 100
    END AS qoq_percentage_change
FROM
    revenue_change
ORDER BY
    quarter_number;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q8] What is the trend of revenue and orders by quarters?

Hint: Find out the sum of revenue and count the number of orders for each quarter.*/
select quarter_number,sum((quantity*vehicle_price)-(quantity*vehicle_price*discount))as revenue,
		count(order_id) from order_t group by quarter_number order by quarter_number;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* QUESTIONS RELATED TO SHIPPING 
    [Q9] What is the average discount offered for different types of credit cards?

Hint: Find out the average of discount for each credit card type.*/
select credit_card_type,avg(discount) from customer_t join order_t using(customer_id) group by credit_card_type;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q10] What is the average time taken to ship the placed orders for each quarters?
	Hint: Use the dateiff function to find the difference between the ship date and the order date.
*/
select quarter_number,avg(datediff(ship_date,order_date)) from order_t group by quarter_number order by quarter_number;

-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------



