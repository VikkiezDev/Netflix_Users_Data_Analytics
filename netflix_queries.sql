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

rename table netflix.user to netflix.users;

show columns from netflix.users;

select * from netflix.users limit 1;

select Country, count(*) as Total_Logins
from netflix.users 
where month(Last_Login) = 3 and year(Last_Login) = 2024
group by Country
order by Total_Logins desc
limit 10;

/*---------------------------------------------------------------
General Analytical Questions
-----------------------------------------------------------------*/

# 1. Retrieve the total number of users in the dataset.

select count(distinct User_ID) as Total_Users 
from netflix.users;

# 2. Find the average age of users for each subscription type.

select Subscription_Type, avg(Age) as Average_Age
from netflix.users
group by Subscription_Type
order by Average_Age desc;

# 3. List the number of users per country.

select Country, count(User_ID) as Total_Users
from netflix.users
group by Country
order by Total_Users desc;

# 4. Determine the most popular subscription type based on user count.

select Subscription_Type, count(User_ID) as User_Count
from netflix.users
group by Subscription_Type
order by User_Count desc limit 1;

# 5. Find the total watch time for each subscription type.

select Subscription_Type, sum(Watch_Time_Hours) as Total_Watch_Time
from netflix.users
group by Subscription_Type
order by Total_Watch_Time desc;

# 6. Calculate the average watch time per user.

select round(avg(Watch_Time_Hours)) as Avg_Watch_Time
from netflix.users;

# 7. Identify the top 5 users who have watched the most hours.

select User_ID, Watch_Time_Hours as Hours_Watched
from netflix.users
order by Hours_Watched desc
limit 5;

# 8. Get the count of users who have logged in within the last 30 days.

SELECT COUNT(User_ID) AS Active_Users_Last_30d  
FROM netflix.users  
WHERE Last_Login >= date_sub(curdate(), interval 30 day);

# 9. Find the percentage of users subscribed to each subscription type.

select Subscription_Type, (count(*)*100)/(select count(*) from netflix.users) as Percentage
from netflix.users
group by Subscription_Type;

# 10. Retrieve the most common favorite genre among all users.

select Favorite_Genre, count(*) as Most_Watched
from netflix.users
group by Favorite_Genre
order by Most_Watched desc
limit 1;

# 11. Identify the least common favorite genre.

select Favorite_Genre, count(*) as Least_Watched
from netflix.users
group by Favorite_Genre
order by Least_Watched asc
limit 1;

# 12. List the number of users for each age group (e.g., 13-18, 19-25, 26-35, etc.).

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

# 13. Find users who have watched more than 100 hours in the last month.

SELECT 
    User_ID, Watch_Time_Hours
FROM netflix.users
WHERE Last_Login >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
GROUP BY User_ID
HAVING Watch_Time_Hours > 100
ORDER BY Watch_Time_Hours DESC;

# 14. Get the country with the highest total watch time.

select Country, sum(Watch_Time_Hours) as Total_Watch_Time
from netflix.users
group by Country
order by Total_Watch_Time desc
limit 1;

# 15. Determine the average watch time per user per country.

select Country, avg(Watch_Time_Hours) as Average_Watch_Time
from netflix.users
group by Country
order by Average_Watch_Time desc;

/*---------------------------------------------------------------
Hidden Insights & Complex Queries
-----------------------------------------------------------------*/











