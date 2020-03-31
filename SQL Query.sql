-- 1. Write the SQL query using the tables "Restaurant_Attributes" and "Order_Fact" to calculate 
--TOTAL ORDERS for each RESTAURANT_ID

SELECT
restaurant_id,
Count(order_id) as TOTAL_ORDERS
from Order_Fact
Group by restaurant_id
Order by TOTAL_ORDERS desc


-- 2. Write the SQL query using the tables "Restaurant_Attributes" and "Order_Fact" to calculate 
--TOTAL REVENUE for each RESTAURANT_ID

SELECT restaurant_id,
Sum(ORDER_VALUE) as TOTAL_REVENUE
From Order_Fact
Group by restaurant_id
Order by TOTAL_REVENUE desc

-- 3. Write the SQL query using the tables "Restaurant_Attributes" and "Order_Fact" to calculate 
--TOTAL DISTINCT CUSTOMERS for each RESTAURANT_ID
SELECT restaurant_id,
COUNT( DISTINCT CUSTOMER_ID)  TOTAL_DISTINCT_CUSTOMERS
From Order_Fact
Group by restaurant_id
Order by TOTAL_DISTINCT_CUSTOMERS desc


-- 4. Write the SQL query using the tables "Restaurant_Attributes" and "Order_Fact" to calculate 
-- TOTAL ORDERS for each RESTAURANT_ID in Cuisine = Juices 

SELECT   RESTAURANT_ID as Juice_Restaurents_ID, TOTAL_ORDERS
FROM(
SELECT O.RESTAURANT_ID, R.CUISINE, COUNT(O.ORDER_ID) as TOTAL_ORDERS
FROM Order_Fact O
LEFT JOIN  Restaurant_Attributes R
ON O.RESTAURANT_ID=R.RESTAURANT_ID
GROUP BY O.RESTAURANT_ID, R.CUISINE
) A
WHERE CUISINE in  ('Juices')

-- 5. Write the SQL query using the tables "Restaurant_Attributes" and "Order_Fact" to calculate 
--TOTAL REVENUE for each RESTAURANT_ID in Cuisine = Biryani

SELECT  RESTAURANT_ID as Restaurents_Biryani, TOTAL_REVENUE
FROM(
SELECT O.RESTAURANT_ID, R.CUISINE, SUM(O.ORDER_VALUE) as TOTAL_REVENUE
FROM Order_Fact O
left join Restaurant_Attributes R
on O.RESTAURANT_ID=R.RESTAURANT_ID
GROUP BY O.RESTAURANT_ID,R.CUISINE
) A
WHERE CUISINE in  ('Biryani')

-- 6. Write the SQL query using the tables "Restaurant_Attributes" and "Order_Fact" to calculate 
--TOTAL ORDERS for each RESTAURANT_ID in Area = Koramangala 

SELECT  RESTAURANT_ID as Koramangala_Restaurents, TOTAL_ORDERS
FROM(
SELECT O.RESTAURANT_ID, R.AREA, COUNT(O.ORDER_ID) as TOTAL_ORDERS
FROM Order_Fact O
left join Restaurant_Attributes R
on O.RESTAURANT_ID=R.RESTAURANT_ID
GROUP BY O.RESTAURANT_ID, R.AREA
) A
WHERE AREA in  ('Koramangala')

-- 7. Write the SQL query using the tables "Restaurant_Attributes" and "Order_Fact" to calculate 
-- TOTAL ORDERS and AVERAGE RATING for each RESTAURANT_ID in Area = Koramangala and Restaurant_Category = A

SELECT   RESTAURANT_ID as Koramangala_A_RestaurentsID, TOTAL_ORDERS, Avg_Rating
FROM(
 SELECT O.RESTAURANT_ID, R.AREA, R.RESTAURANT_CATEGORY,
 COUNT(O.ORDER_ID) as TOTAL_ORDERS, ROUND(AVG(Rating),2) as Avg_Rating
 FROM Order_Fact O
 LEFT JOIN  Restaurant_Attributes R
 ON O.RESTAURANT_ID=R.RESTAURANT_ID
 GROUP BY O.RESTAURANT_ID, R.AREA,R.RESTAURANT_CATEGORY
) A
WHERE AREA in  ('Koramangala') and RESTAURANT_CATEGORY='A'
Order by Avg_Rating desc


-- 8. Write the SQL query using the tables "Restaurant_Attributes" and "Order_Fact" to calculate 
--TOTAL ORDERS and AVERAGE RATING for each RESTAURANT_ID in Area = Indiranagar and Restaurant_Category = B and C

SELECT   RESTAURANT_ID as Indiranagar_RestaurentsID, TOTAL_ORDERS, Avg_Rating
FROM(
 SELECT O.RESTAURANT_ID, R.AREA, R.RESTAURANT_CATEGORY,
 COUNT(O.ORDER_ID) as TOTAL_ORDERS, ROUND(AVG(Rating),2) as Avg_Rating
 FROM Order_Fact O
 LEFT JOIN  Restaurant_Attributes R
 ON O.RESTAURANT_ID=R.RESTAURANT_ID
 GROUP BY O.RESTAURANT_ID, R.AREA,R.RESTAURANT_CATEGORY
) A
WHERE AREA ='Indiranagar' and RESTAURANT_CATEGORY in ('B','C')
Order by Avg_Rating desc

-- 9. Write the SQL query using the tables "Restaurant_Attributes" and "Order_Fact" to calculate 
-- Total number of restaurants in an Area = HSR with Rating >4.0 and AOV >200 and Total Orders >150

SELECT Count(R.RESTAURANT_ID) as Total_Restaurents
FROM(
 SELECT RESTAURANT_ID,
 COUNT(ORDER_ID) as TOTAL_ORDERS
 FROM Order_Fact 
 GROUP BY RESTAURANT_ID) A
RIGHT JOIN Restaurant_Attributes R
ON A.RESTAURANT_ID=R.RESTAURANT_ID
WHERE AREA= 'HSR' AND Rating > 4 AND AOV > 200 AND TOTAL_ORDERS > 150
