create database netflix;
drop table netflix.users;
use netflix;
create table users (
	User_ID int primary key,
    Name varchar(155),
    Age int,
    Country varchar(100),
    Subscription_Type varchar(100),
    Watch_Time_Hours double,
    Favorite_Genre varchar(100),
    Last_Login date
);

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/netflix_users.csv'
into table netflix.users
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

select count(*) as total from netflix.user;

rename table netflix.users to netflix.main;

show columns from netflix.users;

select * from netflix.users limit 1;

/*---------------------------------------------------------------
Break the Database into multiple tables for efficient querying
-----------------------------------------------------------------*/

create table users (
	user_id int primary key,
    name varchar(100),
    age int,
    country varchar(100),
    subscription_type varchar(30)
);

create table watch_history (
	watch_id int auto_increment primary key,
    user_id int,
    watch_time_hours double,
    favorite_genre varchar(50),
    last_login date,
    foreign key(user_id) references users(user_id) on delete cascade
);

create table churn_analysis (
	churn_id int auto_increment primary key,
    user_id int,
    predicted_churn boolean,
    last_updated date,
    foreign key(user_id) references users(user_id) on delete cascade
);

insert into users (user_id, name, age, country, subscription_type)
select distinct user_id, name, age, country, subscription_type
from netflix.main;

insert into watch_history (user_id, watch_time_hours, favorite_genre, last_login)
select distinct user_id, watch_time_hours, favorite_genre, last_login
from netflix.main;

insert into churn_analysis (user_id, predicted_churn, last_updated)
select user_id,
	case when last_login < date_sub(curdate(), interval 6 month) then 1 else 0 end as predicted_churn,
    curdate() as last_updated
from netflix.main;

select count(predicted_churn) as possible_churn
from netflix.churn_analysis
where predicted_churn = 1;

/*---------------------------------------------------------------
General Analytical Questions
-----------------------------------------------------------------*/

# 1. Retrieve the total number of users in the dataset.

select count(distinct user_id) as Total_Users 
from netflix.users;

# 2. Find the average age of users for each subscription type.

select subscription_type, avg(age) as Average_Age
from netflix.users
group by subscription_type
order by Average_Age desc;

# 3. List the number of users per country.

select country, count(user_id) as Total_Users
from netflix.users
group by country
order by Total_Users desc;

# 4. Determine the most popular subscription type based on user count.

select subscription_type, count(user_id) as Total_Users
from netflix.users
group by subscription_type
order by Total_Users desc
limit 1;

# 5. Find the total watch time for each subscription type.

select u.subscription_type, sum(w.watch_time_hours) as Total_Hours
from netflix.users u
join netflix.watch_history w on u.user_id = w.user_id
group by u.subscription_type
order by Total_Hours desc;

# 6. Calculate the average watch time per user.

select round(avg(Watch_Time_Hours)) as Avg_Watch_Time
from netflix.watch_history;

# 7. Identify the top 5 users who have watched the most hours.

select u.user_id, w.watch_time_hours as Watch_hours
from netflix.users u
join netflix.watch_history w on u.user_id=w.user_id
order by Watch_hours desc
limit 5;

# 8. Get the count of users who have logged in within the last 30 days.

SELECT COUNT(u.User_ID) AS Active_Users_Last_30d
FROM netflix.users u
join netflix.watch_history w on u.user_id = w.user_id
WHERE w.last_login >= date_sub(curdate(), interval 30 day);

# 9. Find the percentage of users subscribed to each subscription type.

select u.subscription_type, (count(*)*100)/(select count(*) from netflix.users) as Percentage
from netflix.users u
group by u.subscription_type;

# 10. Retrieve the most common favorite genre among all users.

select w.favorite_genre, count(u.user_id) as Common_Genre
from netflix.users u
join watch_history w on u.user_id = w.user_id
group by w.favorite_genre
order by Common_genre desc
limit 1;

# 11. List the number of users for each age group (e.g., 13-18, 19-25, 26-35, etc.).

select
	case
		when Age between 13 and 18 then "13-18"
        when Age between 19 and 25 then "19-25"
        when Age between 26 and 35 then "26-35"
        when Age between 36 and 50 then "36-50"
        else "51-80"
	end as Age_Group,
    count(*) as User_Per_Group
from netflix.users
group by Age_Group
order by User_Per_Group desc;

# 12. Find users who have watched more than 100 hours in the last month.

SELECT 
    u.user_id, w.watch_time_hours, w.last_login
FROM netflix.users u
join netflix.watch_history w on u.user_id = w.user_id
WHERE w.last_login >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
HAVING w.watch_time_hours > 100
ORDER BY w.watch_time_hours DESC;

# 13. Get the country with the highest total watch time.

select u.country, sum(w.watch_time_hours) as Total_Watch_Time
from netflix.users u
join netflix.watch_history w on u.user_id = w.user_id
group by u.country
order by Total_Watch_Time desc
limit 1;

# 14. Determine the average watch time per user per country.

select u.country, avg(w.watch_time_hours) as Average_Watch_Time
from netflix.users u
join netflix.watch_history w on u.user_id = w.user_id
group by u.country
order by Average_Watch_Time desc;

# 15. What is the total number of users predicted to churn (i.e., where predicted_churn = 1)?

select sum(predicted_churn) as Total_User_Churn
from netflix.churn_analysis
where predicted_churn = 1;

# 16. What percentage of total users are predicted to churn?

select (select sum(c.predicted_churn)*100)/count(u.user_id) as Churn_Percentage
from netflix.users u
join netflix.churn_analysis c on u.user_id = c.user_id;

# 17. List the top 5 countries with the highest number of predicted churn users.

select u.country, sum(c.predicted_churn) as Number_Of_Churned_Users
from netflix.users u
join netflix.churn_analysis c on u.user_id = c.user_id
group by u.country
order by Number_Of_Churned_Users desc
limit 5;

# 18. Find the average watch time of users who are predicted to churn vs. those who are not.

select c.predicted_churn, avg(w.watch_time_hours)
from netflix.watch_history w
join netflix.churn_analysis c on w.user_id = c.user_id
group by c.predicted_churn;

# 19. Determine if a specific subscription type (Basic, Standard, Premium) has a higher churn rate

select u.subscription_type, (select (sum(c.predicted_churn)*100)/count(u.user_id)) as Churn_Rate
from netflix.users u
join netflix.churn_analysis c on u.user_id = c.user_id
group by u.subscription_type
order by Churn_Rate desc;

# 20. Find the most common favorite genre among users predicted to churn.

select w.favorite_genre, sum(c.predicted_churn) as Churn_Per_Genre
from netflix.watch_history w
join netflix.churn_analysis c on w.user_id = c.user_id
group by w.favorite_genre
order by Churn_Per_Genre desc
limit 1;

/*---------------------------------------------------------------
Hidden Insights & Complex Queries
-----------------------------------------------------------------*/

/*---------------------------------------------------------------
Stored Procedures
-----------------------------------------------------------------*/
# Using Stored Procedures to gain Country-wise statistics

-- Country = France | USA | India | Canada | Mexico | Japan | Australia | Germany | Brazil | UK
-- Total_users
-- Average_watch_time
-- Favorite_genre
-- Subscription_type
-- Churn_rate

drop procedure if exists `analytics_by_country`;

delimiter $$
create procedure analytics_by_country(country_name varchar(100))
begin
	select 
		u.country, 
        count(u.user_id) as Total_Users, 
        round(avg(w.watch_time_hours), 2) as Average_Watch_Time, 
			
            (select u2.subscription_type 
			 from netflix.users u2
			 where u2.country = country_name
			 group by u2.subscription_type
			 order by COUNT(*) DESC
			 limit 1) AS Preferred_Subscription_Type,
        
			(select w2.favorite_genre
			from netflix.watch_history w2
			join netflix.users u2 on u2.user_id = w2.user_id
			where u2.country = country_name
			group by w2.favorite_genre
			order by count(u2.country) desc
			limit 1) as Most_Common_Genre,
        
			round((select (sum(c.predicted_churn)*100)/count(u3.user_id) as Percentage
			from netflix.churn_analysis c
			join netflix.users u3 on u3.user_id = c.user_id
			where u3.country = country_name), 2) as Churn_Rate
        
	from netflix.users u
	join netflix.watch_history w on u.user_id = w.user_id
	where u.country = country_name
	group by u.country;
end $$
delimiter ;

call analytics_by_country('France');

/*---------------------------------------------------------------
Indexing & Query Optimization
-----------------------------------------------------------------*/

CREATE INDEX idx_country ON netflix.users(country);

# The stored procedure for the country "France" 
-- took 0.141 secs to complete and print the output before indexing,
-- the same stored procedure for the country "France" after indexing took only 0.047 secs to complete and print the output.

