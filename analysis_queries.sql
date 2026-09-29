use pro_crimes;

-- ============================================================
-- 4. EXPLORATORY DATA ANALYSIS / SQL ANALYSIS QUERIES
-- ============================================================
-- This file contains SQL analysis queries performed on the
-- cleaned crime_inc table after data cleaning and validation.
-- ============================================================



-- ------------------------------------------------------------
-- 4.1 OVERALL CRIME DISTRIBUTION ANALYSIS
-- ------------------------------------------------------------

-- 1. Count total incidents for each crime type
select crime_type,count(*) total_crimes 
from crime_inc 
group by crime_type 
order by count(*) desc;

-- 2. Identify the most frequently reported crime type
select crime_type,count(*) as total_crimes 
from crime_inc 
group by crime_type 
order by total_crimes desc 
limit 1;

-- 3. Identify the least frequently reported crime type
select crime_type,count(*) total_crimes 
from crime_inc 
group by crime_type 
order by total_crimes 
limit 1;



-- ------------------------------------------------------------
-- 4.2 LOCATION-BASED CRIME ANALYSIS
-- ------------------------------------------------------------

-- 4. Count total incidents for each crime type across cities
select city,crime_type,count(*) total_crimes 
from crime_inc 
group by city,crime_type  
order by city;

-- 5. Find the top 5 cities with the highest number of crime incidents
select city,count(*) total_crimes 
from crime_inc 
group by city 
order by count(*) desc 
limit 5;

-- 6. Find the top 3 districts with the highest number of crime incidents
select district,count(*) total_crimes 
from crime_inc 
group by district 
order by count(*) desc 
limit 3;

-- 7. Identify the most common crime type in each city
with common_crime as (
select city,crime_type,count(*) as total_crimes,
row_number() over(partition by city order by count(*) desc) as crimes
from crime_inc 
group by city,crime_type
)
select city,crime_type,total_crimes 
from common_crime 
where crimes=1;

-- 8. Identify the least common crime type in each city
with common_crime as (
select city,crime_type,count(*) as total_crimes,
row_number() over(partition by city order by count(*)) as crimes
from crime_inc 
group by city,crime_type
)
select city,crime_type,total_crimes 
from common_crime 
where crimes=1;

-- 9. Identify the most common crime type in each district
with crime_cte as (
select district,crime_type,count(*) total_crime_num,
row_number() over(partition by district order by count(*) desc) as rn
from crime_inc 
group by district,crime_type
)
select district,crime_type,total_crime_num 
from crime_cte 
where rn=1;

-- 10. Identify the least common crime type in each district
with crime_cte as (
select district,crime_type,count(*) total_crime_num,
row_number() over(partition by district order by count(*)) as rn
from crime_inc 
group by district,crime_type
)
select district,crime_type,total_crime_num 
from crime_cte 
where rn=1;

-- 11. Calculate the average number of crime incidents per city
SELECT AVG(total_crimes) AS avg_crimes_per_city 
FROM (
    SELECT city,COUNT(*) AS total_crimes 
    FROM crime_inc 
    GROUP BY city
) t;

-- 12. Calculate the average number of crime incidents per district
SELECT AVG(total_crimes) AS avg_crimes_per_city
FROM (
    SELECT district,
           COUNT(*) AS total_crimes
    FROM crime_inc
    GROUP BY district
) t;



-- ------------------------------------------------------------
-- 4.3 TIME-BASED CRIME ANALYSIS
-- ------------------------------------------------------------

-- 13. Analyze yearly crime volume across cities
select city,year(incident_datetime) years,count(*) total_crimes 
from crime_inc 
group by city,year(incident_datetime) 
order by year(incident_datetime) desc;

-- 14. Analyze the monthly distribution of crime incidents
select monthname(incident_datetime) month,count(*) total_crimes 
from crime_inc 
where incident_datetime is not null 
group by month(incident_datetime),monthname(incident_datetime) 
order by month(incident_datetime);

-- 15. Analyze district-wise crime occurrence by hour of the day
select district,hour(incident_datetime) hours,count(*) as total_crimes 
from crime_inc 
group by district,hour(incident_datetime) 
order by hour(incident_datetime) desc,district;

-- 16. Find the most common crime-hour combination
select hour(incident_datetime) as hours,crime_type,count(*) as crime_numbers 
from crime_inc 
where incident_datetime is not null 
group by hours,crime_type 
order by crime_numbers desc 
limit 1;

-- 17. Identify the hour of the day with the highest number of crimes
SELECT HOUR(incident_datetime) AS hours,COUNT(*) AS total_crimes 
FROM crime_inc 
WHERE incident_datetime IS NOT NULL 
GROUP BY hours 
ORDER BY total_crimes DESC 
LIMIT 1;



-- ------------------------------------------------------------
-- 4.4 OFFICER WORKLOAD ANALYSIS
-- ------------------------------------------------------------

-- 18. Count total cases handled by each officer
select officer_id,count(*) as crime_handled 
from crime_inc 
group by officer_id;



-- ------------------------------------------------------------
-- 4.5 RANKING AND WINDOW FUNCTION ANALYSIS
-- ------------------------------------------------------------

-- 19. Rank crime types by total incidents using DENSE_RANK()
with ranking as (
select crime_type,count(*) as crime_numbers,
dense_rank() over(order by count(*) desc) crime_rank
from crime_inc 
group by crime_type
)
select * 
from ranking;

-- 20. Rank crime types by total incidents using RANK()
with ranking as (
select crime_type,count(*) as crime_numbers,
rank() over(order by count(*) desc) crime_rank
from crime_inc 
group by crime_type
)
select * 
from ranking;