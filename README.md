# Netflix User Behavior & Subscription Analytics

## Setup

### **Download**
- vwrvw

### **Importing methods**
- rwv

## Break the Database into multiple tables for efficient querying 
- Users (User_ID, Name, Age, Country, Subscription_Type)
- Watch_History (User_ID, Watch_Time_Hours, Favorite_Genre, Last_Login)
- Churn_Analysis (User_ID, Predicted_Churn, LastUpdated)
```
SELECT c.User_ID, c.Last_Login,
       CASE WHEN c.Last_Login < DATE_SUB(CURDATE(), INTERVAL 6 MONTH) 
            THEN 'Churned' ELSE 'Active' END AS Churn_Status
FROM Churn_Analysis c;
```

## MySQL Querying
### **General Analytical Questions**
1. Retrieve the total number of users in the dataset.  
2. Find the average age of users for each subscription type.  
3. List the number of users per country.  
4. Determine the most popular subscription type based on user count.  
5. Find the total watch time for each subscription type.  
6. Calculate the average watch time per user.  
7. Identify the top 5 users who have watched the most hours.  
8. Get the count of users who have logged in within the last 30 days.  
9. Find the percentage of users subscribed to each subscription type.  
10. Retrieve the most common favorite genre among all users.  
11. Identify the least common favorite genre.  
12. List the number of users for each age group (e.g., 13-18, 19-25, 26-35, etc.).  
13. Find users who have watched more than 100 hours in the last month.  
14. Get the country with the highest total watch time.  
15. Determine the average watch time per user per country.  

### **Hidden Insights & Complex Queries**
16. Find out if there is a correlation between subscription type and watch time.  
17. Identify users who haven't logged in for more than 6 months but still have an active subscription.  
18. Retrieve users with unusually high watch time (outliers in watch time distribution).  
19. Determine which country has the highest average watch time per user.  
20. Find the top 3 countries with the most Premium subscription users.  
21. Identify any age groups that prefer a specific genre the most.  
22. Check if users who watch more tend to have a higher subscription tier.  
23. Find users whose last login was more than 3 months ago but have high watch hours.  
24. Retrieve users with very low watch time (e.g., below 10 hours in the last month).  
25. Determine if younger users (under 25) prefer a specific subscription type.  
26. Find the most frequent last login day of the week across all users.  
27. Calculate the average watch time per login session for each user.  
28. Identify seasonal trends in last login dates (e.g., more logins in winter/summer months).  
29. Find users who downgraded from Premium to Basic (requires tracking subscription changes).  
30. Determine whether users with longer watch hours also have longer session gaps in logins.

## Important Functionalities
### **Stored Procedures & Views** 
– Automate reporting & make querying efficient.



### **Indexing & Query Optimization**
– Speed up large dataset operations.



## Charts
