#Section A: Level 1 Questions

#1.	Read the data from all the tables
select * from customer;
select * from Orders;
select * from Supplier;
select * from Product;
select * from OrderItem;

#2.	Find the country-wise count of customers. 
select country,count(id) from customer group by Country;

#3.	Display the products that are not discontinued. 
select productname from product where IsDiscontinued=1;

#4.	Display the list of companies along with the product name that they are supplying. 
select companyname,productname from product p join supplier s on s.id=p.supplierid;

#5.	Display customer information about who stays in 'Mexico'
select * from customer where country='Mexico';

#Additional: Level 1 questions

#6.	Display the costliest item that is ordered by the customer.
select productname from product p join orderitem oi on p.Id=oi.ProductId order by oi.unitprice desc limit 1;

#7.	Display supplier ID who owns the highest number of products.
select s.id,count(*) from supplier s join product p on s.Id=p.supplierId group by s.id order by count(*) desc limit 2;

#8.	Display month-wise and year-wise counts of the orders placed.
select month(orderdate),year(orderdate),count(id) from orders group by month(orderdate),year(orderdate);

#9.	Which country has the maximum number of suppliers?
select country,count(id) from supplier group by country order by Country desc limit 1;

#10.	Which customers did not place any orders?
select c.id,c.FirstName,c.LastName from customer c left join orders o on c.id=o.CustomerId where o.id is null;

#Section B: Level 2 Questions:

#1.	Arrange the Product ID and Name based on the high demand by the customer.
select p.id,productname,count(Quantity) from product p join orderitem oi on p.id=oi.ProductId group by p.id,productname order by count(Quantity) desc;

#2.	Display the total number of orders delivered every year
select count(*),year(orderdate) from orders group by year(orderdate);

#3.	Calculate year-wise total revenue. 
select year(orderdate),sum(totalamount) from orders group by year(orderdate);

#4.	Display the customer details whose order amount is maximum including his past orders. 
select c.id,c.FirstName,c.LastName,sum(o.TotalAmount) from customer c join orders o on o.customerid=c.id 
													  group by c.id,c.FirstName,c.LastName order by sum(o.TotalAmount) desc limit 1;

#5.	Display the total amount ordered by each customer from high to low.
select c.id,c.FirstName,c.LastName,sum(o.TotalAmount) from customer c join orders o on o.customerid=c.id 
													  group by c.id,c.FirstName,c.LastName order by sum(o.TotalAmount) desc;

#Additional Level 2 Questions: 6 n 7 ignored

#1.	Display the latest order date (should not be the same as the first order date) of all the customers with customer details. 
select c.id,c.FirstName,c.LastName,max(OrderDate),count(*) from customer c join orders o on o.customerid=c.id group by c.id,c.FirstName,c.LastName having count(*)>1;

#2.	Display the product name and supplier name for each order
select o.*,companyname,ProductName from supplier s join product p on p.supplierid=s.id 
													join orderitem oi on oi.ProductId=p.id 
                                                    join orders o on o.id=oi.OrderId;

#Section C: Level 3 Questions:

#1.	Fetch the customer details who ordered more than 10 products in a single order.
select c.id,c.FirstName,c.LastName,o.id,count(productid) from customer c join orders o on o.CustomerId=c.Id
																		 join orderitem oi on o.id=oi.OrderId 
                                                                         group by c.id,c.FirstName,c.LastName,o.id having count(ProductId)>10;

#2.	Create a combined list to display customers and supplier lists as per the below format.
SELECT 'Customer' AS Type,firstname,City,Country,Phone FROM Customer
UNION
SELECT 'Supplier' AS Type,companyname,City,Country,Phone FROM Supplier;


#Section D: Level 4 Questions:

#1.	Create a combined list to display customers' and suppliers' details considering the following criteria 
	#a.	Both customer and supplier belong to the same country 
	#b.	Customers who do not have a supplier in their country
	#c.	A supplier who does not have customers in their country
    select*from customer left join supplier using(country)
    union
    select*from customer right join supplier using(country);

#2.	Find out for which products, the UK is dependent on other countries for the supply. List the countries which are supplying these products in the same list.
select c.country,productname,s.country from customer c join orders o on o.CustomerId=c.id
														join orderitem oi on oi.OrderId=o.Id
														join product p on oi.ProductId=p.id
                                                        join supplier s on p.SupplierId=s.id where c.country='UK' and s.Country<>'UK';
                                                        
