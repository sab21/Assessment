

-- Table Name: Sales Data = sales_data,  Store Details = store_details and Calendar =calendar


--============ Q1 =================

SELECT week_num as "Week Number"
  , sales_wtd_ty as "Sales WTD TY"
  , SUM(sales_wtd_ty) OVER (partition by period ORDER BY week_num 
    ROWS between UNBOUNDED PRECEDING AND CURRENT ROW 
    ) as "Sales PTD TY" 
  , SUM(sales_wtd_ty) OVER (ORDER BY week_num) as "Sales YTD TY"
  , sales_wtd_ly as "Sales WTD LY"
  , SUM(sales_wtd_ly) OVER (partition by period ORDER BY week_num 
    ROWS between UNBOUNDED PRECEDING AND CURRENT ROW 
    ) as "Sales PTD LY"
  , SUM(sales_wtd_ly) OVER (ORDER BY week_num) as "Sales YTD LY"
  , sales_unit_wtd_ty as "Sales Units WTD TY"
  , SUM(sales_unit_wtd_ty) OVER (partition by period ORDER BY week_num 
    ROWS between UNBOUNDED PRECEDING AND CURRENT ROW 
    ) as "Sales Units PTD TY"
  , SUM(sales_unit_wtd_ty) OVER (ORDER BY week_num) as "Sales Units YTD TY"
FROM (
Select distinct c1."Q_WK_NUMBER" as week_num
  , CASE WHEN c1."Q_WK_NUMBER"  between 1 and 4 then 1 
        WHEN c1."Q_WK_NUMBER"  between 5 and 9 then 2 
        WHEN c1."Q_WK_NUMBER"  between 10 and 13 then 3 
        WHEN c1."Q_WK_NUMBER"  between 14 and 17 then 4 
        WHEN c1."Q_WK_NUMBER"  between 18 and 22 then 5 
        WHEN c1."Q_WK_NUMBER"  between 23 and 26 then 6 
        WHEN c1."Q_WK_NUMBER"  between 27 And 30 then 7 
        WHEN c1."Q_WK_NUMBER"  between 31 and 35 then 8 
        WHEN c1."Q_WK_NUMBER"  between 36 and 39 then 9 
        WHEN c1."Q_WK_NUMBER"  between 40 and 43 then 10 
        WHEN c1."Q_WK_NUMBER"  between 44 and 48 then 11
        WHEN c1."Q_WK_NUMBER"  between 49 and 52 then 12
      END  as period
  , (SELECT SUM(s."Sales" ) FROM sales_data s LEFT JOIN calendar c ON c."Q_DT_ID" = s."Date" 
      WHERE s."Date" >= '2021-01-31 00:00:00' AND c."Q_WK_NUMBER" =c1."Q_WK_NUMBER") as sales_wtd_ty
  , (SELECT SUM(s."Sales" ) FROM sales_data s LEFT JOIN calendar c ON c."Q_DT_ID" = s."Date" 
      WHERE s."Date" >= '2020-02-02 00:00:00' AND s."Date" < '2021-01-31 00:00:00' 
      AND c."Q_WK_NUMBER" =c1."Q_WK_NUMBER") as sales_wtd_ly
  , (SELECT SUM(s."Sold Units" ) FROM sales_data s LEFT JOIN calendar c ON c."Q_DT_ID" = s."Date" 
      WHERE s."Date" >= '2021-01-31 00:00:00' AND c."Q_WK_NUMBER" =c1."Q_WK_NUMBER") as sales_unit_wtd_ty
FROM calendar c1) A

--------------xxx------------------xxx------------------


--=========== Q2 Top 3 performing weeks country wise==============
SELECT week_num as "Week Number"
  , country as "Country"
  , sales_wtd_ty as "Sales WTD" 
From (
SELECT DISTINCT week_num 
  , country 
  , sales_wtd_ty 
  , DENSE_RANK() OVER(Partition By country ORDER BY sales_wtd_ty DESC) rno
FROM (
SELECT c1."Q_WK_NUMBER" as week_num , st1."Country" as country 
    --, s."Sales"  as sales
    , (SELECT SUM(s."Sales" ) FROM sales_data s LEFT JOIN calendar c ON c."Q_DT_ID" = s."Date" 
      LEFT JOIN store_details st ON s."Store Number" = st."Store Number"
      WHERE s."Date" >= '2021-01-31 00:00:00' AND c."Q_WK_NUMBER" =c1."Q_WK_NUMBER"
      AND st."Country"= st1."Country") as sales_wtd_ty
FROM sales_data s1 
LEFT JOIN calendar c1 ON c1."Q_DT_ID" = s1."Date"
LEFT JOIN store_details st1 ON st1."Store Number" = s1."Store Number" 
WHERE c1."Q_WK_NUMBER"<24 -- week 24 onward has no data
ORDER by 1, 2
)A )B
WHERE  rno <= 3
Order BY sales_wtd_ty desc 
--Order BY sales_wtd_ty desc NULLS LAST --limit 3

-------------xxx----------------xxx--------------------


--=========== Q3 Top three performing Stores==============

SELECT week_num 
  , store_number, store_name 
  , sales_wtd_ty 
  -- , DENSE_RANK() OVER(Partition By week_num ORDER BY sales_wtd_ty DESC) rno
FROM (
SELECT distinct week_num, store_number, store_name
    , SUM(sales) over (partition by store_number order by week_num) as sales_wtd_ty
From(
SELECT c."Q_WK_NUMBER" as week_num 
    , st."Store Number" as store_number
    , st."Store Name" as store_name
    , s."Sales" as sales
      FROM sales_data s LEFT JOIN calendar c ON c."Q_DT_ID" = s."Date" 
      LEFT JOIN store_details st ON s."Store Number" = st."Store Number"
      WHERE s."Date" >= '2021-01-31 00:00:00' AND c."Q_WK_NUMBER" =15
) A)B
order by sales_wtd_ty desc limit 3

--=========== Q3 Bottom three performing Stores==============
SELECT * FROM (
SELECT week_num 
  , store_number, store_name 
  , sales_wtd_ty 
  -- , DENSE_RANK() OVER(Partition By week_num ORDER BY sales_wtd_ty DESC) rno
FROM (
SELECT distinct week_num, store_number, store_name
    , SUM(sales) over (partition by store_number order by week_num) as sales_wtd_ty
From(
SELECT c."Q_WK_NUMBER" as week_num 
    , st."Store Number" as store_number
    , st."Store Name" as store_name
    , s."Sales" as sales
      FROM sales_data s LEFT JOIN calendar c ON c."Q_DT_ID" = s."Date" 
      LEFT JOIN store_details st ON s."Store Number" = st."Store Number"
      WHERE s."Date" >= '2021-01-31 00:00:00' AND c."Q_WK_NUMBER" =15
) A)B
order by sales_wtd_ty asc limit 3
) C
order by sales_wtd_ty desc

------------xx-------------xx---------------------



----------- Q4 Pivot by country ------------------
SELECT week_num
  , SUM(CASE WHEN TRIM(country) = 'US' THEN sales_wtd_ty ELSE 0 END )  as "US_Sales_WTD_TY"
  , SUM(CASE WHEN TRIM(country)  = 'US' THEN sales_wtd_ly ELSE 0 END )  as "US_Sales_WTD_LY"
  , SUM(CASE WHEN TRIM(country) = 'CA' THEN sales_wtd_ty ELSE 0 END )  as "CA_Sales_WTD_TY"
  , SUM(CASE WHEN TRIM(country)  = 'CA' THEN sales_wtd_ly ELSE 0 END )  as "CA_Sales_WTD_LY"

FROM (

Select distinct c1."Q_WK_NUMBER" as week_num
  , st1."Country" as country
  --, st1."Store Number" as store_num
  , (SELECT SUM(s."Sales" ) FROM sales_data s LEFT JOIN calendar c ON c."Q_DT_ID" = s."Date" 
      LEFT JOIN store_details st ON s."Store Number" = st."Store Number"
      WHERE s."Date" >= '2021-01-31 00:00:00' AND c."Q_WK_NUMBER" =c1."Q_WK_NUMBER"
      AND st."Country"= st1."Country") as sales_wtd_ty
  , (SELECT SUM(s."Sales" ) FROM sales_data s LEFT JOIN calendar c ON c."Q_DT_ID" = s."Date" 
      LEFT JOIN store_details st ON s."Store Number" = st."Store Number"
      WHERE s."Date" >= '2020-02-02 00:00:00' AND s."Date" < '2021-01-31 00:00:00' 
      AND c."Q_WK_NUMBER" =c1."Q_WK_NUMBER" AND st."Country"= st1."Country") as sales_wtd_ly
FROM calendar c1
LEFT JOIN sales_data s1 ON c1."Q_DT_ID" = s1."Date"
LEFT JOIN store_details st1 ON st1."Store Number" = s1."Store Number" 
) A
GROUP BY 1
Order By 1

------x----------x--------------x--------------



-- ----------Q5 weekly average Sales value -------------------
-- Since there is NO data in latest 6 weeks  I am considering latest 12 week data
SELECT "Store Number" 
    , ROUND(AVG(sales::INTEGER),2)  as "Average Sales WTD"
    , ROUND(AVG(units),2) as "Average Sold Units WTD"
FROM (
SELECT st."Store Number" 
    --, st."Store Name" as store_name
    , s."Sales" as sales
    , s."Sold Units" as units
FROM sales_data s LEFT JOIN calendar c ON c."Q_DT_ID" = s."Date" 
LEFT JOIN store_details st ON s."Store Number" = st."Store Number"
WHERE DATE (s."Date") >= DATE (now() - interval '12 week')  
-- Since there is NO data in latest 6 weeks  I am considering latest 12 week data
)A
GROUP BY 1
ORDER BY 1

-----------------x--x---------x--x---------------------
