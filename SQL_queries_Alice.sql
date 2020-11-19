#some of the ids are duplicates, check if the rows are duplicates

SELECT count(date), id FROM regression_data_clean
GROUP BY id
HAVING  COUNT(id) > 1;

#the rows are not duplicates, the house was sold and then resold in thze given time period

SELECT floors FROM rdc;


# 5)  drop the column date . Select all the data from the table to verify 
# if the command worked. Limit your returned results to 10

ALTER TABLE `house_price_regression`.`regression_data_clean` 
RENAME TO  `house_price_regression`.`rdc` ;

#float was imported per default as int, eventhough in pandas it is imported as a float, which also makes more sense
#CHANGE COLUMN 'floors' FLOAT NULL DEFAULT NULL;
#this query does not work, also changin the dtype manually over the 

ALTER TABLE rdc DROP COLUMN date;

#6) Use sql query to find how many rows of data you have.

SELECT COUNT(*) FROM rdc;

#I got 21597 rows


# 7) Now we will try to find the unique values in some of the categorical columns:

#maybe better would have put this into a formula

SELECT DISTINCT bedrooms FROM rdc ORDER BY bedrooms ASC; 

SELECT DISTINCT bathrooms FROM rdc ORDER BY bathrooms ASC; 

SELECT DISTINCT floors FROM rdc ORDER BY floors ASC; 

SELECT DISTINCT conditions FROM rdc ORDER BY conditions ASC; 

SELECT DISTINCT grade FROM rdc ORDER BY grade ASC;


#8) Arrange the data in a decreasing order by the price of the house. Return only the 
#IDs of the top 10 most expensive houses in your data.

SELECT id, price FROM rdc
ORDER BY price DESC 
LIMIT 10;


#9) What is the average price of all the properties in your data?

SELECT round(AVG(price),2) FROM rdc;

#The average price is 540296.57 USD. (I assume it is USD since it is data from Seattle.alter


# 10 a)What is the average price of the houses grouped by bedrooms? 

SELECT bedrooms, round(AVG(price),2) as Average_Price FROM rdc
GROUP BY bedrooms;


#10 b) What is the average sqft_living of the houses grouped by bedrooms? The returned 
#result should have only two columns, bedrooms and Average of the sqft_living. 
#Use an alias to change the name of the second column.

SELECT bedrooms, round(AVG(sqft_living15),2) as Average_sqft_living FROM rdc
GROUP BY bedrooms;

# 10 c) What is the average price of the houses with a waterfront and without a waterfront? 
#The returned result should have only two columns, waterfront and 
#Average of the prices. Use an alias to change the name of the second column.

SELECT DISTINCT waterfront, AVG(price) OVER (partition by waterfront) as Average_Price
FROM rdc;

#why this didn't work??
#SELECT DISTINCT waterfront, round(AVG(price),2)  OVER (partition by waterfront) as Average_Price
#FROM rdc;

# 10 d) Is there any correlation between the columns condition and grade? You can analyse this by 
#grouping the data by one of the variables and then aggregating the results of the other column. 
#Visually check if there is a positive correlation or negative correlation or no correlation between the variables.


SELECT conditions, avg(grade) as AVG_Grade FROM rdc
GROUP BY conditions
ORDER BY conditions DESC;

SELECT grade, avg(conditions) as AVG_Conditions FROM rdc
GROUP BY grade
ORDER BY grade DESC;


# doesn't look like there is any correlation between the two


# 11) One of the customers is only interested in the following houses:

#Number of bedrooms either 3 or 4
#Bathrooms more than 3
#One Floor
#No waterfront
#Condition should be 3 at least
#Grade should be 5 at least
#Price less than 300000


SELECT count(*) FROM rdc
WHERE bedrooms = 3 OR bedrooms = 4
AND bathrooms >3
AND floors = 1
AND waterfront = 0
AND conditions >= 3
AND grade >= 5
AND price < 300000;



# 12) Your manager wants to find out the list of properties whose prices are twice more 
#than the average of all the properties in the database. Write a query to show them 
#the list of such properties. You might need to use a sub query for this problem.

#Subquery
SELECT 2* round(AVG(price), 2)  as twice_aVG_price from rdc;

SELECT id, price FROM rdc
WHERE price >= 
(
SELECT 2* AVG(price) as twice_aVG_price from rdc
)
ORDER BY price DESC;




# 13) Since this is something that the senior management is regularly interested in, 
#create a view of the same query.

CREATE VIEW house_price_twice_average AS
SELECT id, price FROM rdc
WHERE price >= 
(
SELECT 2* AVG(price) as twice_aVG_price from rdc
)
ORDER BY price DESC;


# 14) Most customers are interested in properties with three or four bedrooms. 
#What is the difference in average prices of the properties with three and four bedrooms?





#Subquery 1
#SELECT DISTINCT bedrooms, AVG(price) OVER (partition by bedrooms ) as AVG_price3 
#FROM rdc
#WHERE bedrooms = 3


WITH cte_bedroom3 AS
(
SELECT DISTINCT bedrooms, AVG(price) OVER (partition by bedrooms ) as price3 
FROM rdc
WHERE bedrooms = 3
),
cte_bedroom4 AS
(
SELECT DISTINCT bedrooms, AVG(price) OVER (partition by bedrooms ) as price4
FROM rdc
WHERE bedrooms = 4
)
SELECT round(price4,2), round(price3,2), round(price4-price3,2) as Difference_Price
FROM cte_bedroom3 
CROSS JOIN cte_bedroom4;


# 15) What are the different locations where properties are available in your database? (distinct zip codes)

SELECT distinct zipcode FROM rdc
ORDER BY zipcode ASC;


# 16) Show the list of all the properties that were renovated.


# I assume that all the properties that where renovated have an entry in the column yr_renovates
#however looking at how the change in size of the living space & lot space over time ( comparing 
#sqrt_living & sqrt_lot  with sqrt_living15 & sqrt_lot15) I assume that a lot of the houses were extended or remodeled in a way. 
#for me this also goes as renovation, but I would clarify this then with the manager)

SELECT id, yr_renovated FROM rdc
WHERE NOT yr_renovated =  0
ORDER BY id ASC;


SELECT id, sqft_living, sqft_living15 FROM rdc
WHERE NOT sqft_living = sqft_living15
ORDER BY id ASC;



# 17) Provide the details of the property that is the 11th most expensive property in your database

WITH rank_price AS
(
SELECT *, rank() over (ORDER BY price DESC) as 'Rank'
from rdc
)
SELECT * FROM rank_price
LIMIT 10,1;


"""
#WHERE Rank = 11;

ELECT id, price, rank() over (ORDER BY price DESC) as 'Rank'
from rdc;

#WITH eleven_expensive AS 
#(
SELECT *, rank() over (ORDER BY price DESC) as 'Rank'
from rdc
)
SELECT *
FROM eleven_expensive
CROSS JOIN rdc 
WHERE Rank = 11;


#id, price, rank() over (ORDER BY price DESC) as 'Rank'
#from rdc
#WHERE Rank = 11;

"""




