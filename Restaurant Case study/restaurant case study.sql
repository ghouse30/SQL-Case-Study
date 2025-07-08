create database restaurant;
use restaurant;
select*from geoplaces2;
-- Question 1: - We need to find out the total visits to all restaurants under all alcohol categories available.
select r.placeid,name,alcohol,count(r.userid)as total_visits from geoplaces2 g join rating_final r using(placeid) group by 1,2,3;

-- Question 2: -Lets find out the average rating according to alcohol and price so that we can understand the rating in respective price categories as well.
select alcohol,price,avg(rating)as avg_rat from geoplaces2 g join rating_final r using(placeid) group by 1,2;

-- Question 3:  Let’s write a query to quantify that what are the parking availability as well in different alcohol categories along with the total number of restaurants.
select parking_lot,alcohol,count(g.placeid)as total_restaurants from geoplaces2 g join chefmozparking c using(placeid) group by 1,2;

-- Question 4: -Also take out the percentage of different cuisines in each alcohol type.
select distinct rcuisine,alcohol,count(rcuisine)over(partition by rcuisine,alcohol)/(select count(rcuisine) from usercuisine) as percent
from geoplaces2 g join chefmozparking c using(placeid) join usercuisine u group by 1,2;

select  distinct alcohol, Rcuisine, (count(placeid) over(partition by rcuisine,alcohol) / count(placeid) over(partition by alcohol) )*100 as Percentage
from geoplaces2 g join chefmozcuisine c using (placeid);

-- Question 5: - let’s take out the average rating of each state.
select state,avg(rating) as avg_rat from geoplaces2 g join rating_final r using(placeid) group by 1 order by 2;

-- Question 6: -' Tamaulipas' Is the lowest average rated state. Quantify the reason why it is the lowest rated by providing the summary based on State, alcohol, and Cuisine.
select distinct alcohol,rcuisine,avg(rating) from geoplaces2 g join chefmozcuisine c using(placeid) join rating_final r using(placeid)
where state='Tamaulipas' group by 1,2;

-- Question 7:  - Find the average weight, food rating, and service rating of the customers who have visited KFC and 
				-- tried Mexican or Italian types of cuisine, and also their budget level is low.
				-- We encourage you to give it a try by not using joins.
select avg(weight), avg(food),avg(rating) from
(select avg(weight) as weight,
(select avg(food_rating) from rating_final r where u.userid=r.userid) as food,(select avg(service_rating) from rating_final r where u.userid=r.userid) as rating
from userprofile u where budget='low' 
and userid in (select userid from usercuisine where rcuisine in ('Mexican','Italian')) 
and userid in (select userid from rating_final where placeid in(select placeid from geoplaces2 where name='kfc'))
group by 2,3)a;


select avg(weight), avg(food_rating), avg(service_rating) from
	(select weight, (select avg(food_rating) from rating_final r where r.userid = u.userid )as  food_rating, 
		(select avg(service_rating) from rating_final r where r.userid = u.userid  ) as service_rating
		  from userprofile u where userid in 
				(select userid from userprofile where budget = 'low'
				intersect
				select userid from usercuisine where rcuisine in ('Mexican', 'Italian')
				intersect
				select userid from rating_final where placeid in (select placeid from geoplaces2 where 
				name = 'KFC'))) a;


-- Trigger for Backup up student details
use class;
drop table if exists student;
create table student (name varchar(20));
insert into student values ('Bob'), ('Alan'), ('Tim'), ('Mike');
create table student_backup (name varchar(20));
create trigger del_trigger
before delete on student
for each row insert into student_backup values(old.name);
select * from student;
select * from student_backup;
delete from student where name = 'Bob';


