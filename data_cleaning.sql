-- ============================================================
-- 2. DATA CLEANING
-- ============================================================


-- ------------------------------------------------------------
-- 2.1 DUPLICATE DETECTION
-- Checking whether duplicate crime incident records exist in the
-- imported dataset based on all major identifying columns.
-- ------------------------------------------------------------

select incident_id,crime_type,district,city,state,address,latitude,longitude,incident_datetime,officer_id,count(*) 
from crime_incidents 
group by incident_id,crime_type,district,city,state,address,latitude,longitude,incident_datetime,officer_id  
having count(*)>1 
order by incident_id;

-- Alternative duplicate check using ROW_NUMBER()
with duplicate_cte as
(select *,row_number() over(partition by incident_id,crime_type,district,city,state,address,latitude,longitude,incident_datetime,officer_id order by incident_id ) as row_num from crime_incidents )
select * from duplicate_cte where row_num>1;


-- ------------------------------------------------------------
-- 2.2 CREATING CLEANING TABLE FOR DEDUPLICATION
-- Creating a working table (crime_inc) to store data along with
-- row numbers, so duplicate rows can be removed safely while
-- preserving the original imported table.
-- ------------------------------------------------------------

CREATE TABLE `crime_inc` (
  `incident_id` text,
  `crime_type` text,
  `district` text,
  `city` text,
  `state` text,
  `address` text,
  `latitude` double DEFAULT NULL,
  `longitude` double DEFAULT NULL,
  `incident_datetime` text,
  `officer_id` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into crime_inc
select *,row_number() over(partition by incident_id,crime_type,district,city,state,address,latitude,longitude,incident_datetime,officer_id) as row_num
from crime_incidents;


-- ------------------------------------------------------------
-- 2.3 DUPLICATE REMOVAL
-- Removing duplicate records from the working table by deleting
-- rows where row_num > 1, keeping only the first occurrence.
-- ------------------------------------------------------------

delete from crime_inc where row_num>1;


-- ------------------------------------------------------------
-- 2.4 DUPLICATE VALIDATION AFTER REMOVAL
-- Rechecking duplicates after deletion to ensure only unique
-- records remain in the cleaned working table.
-- ------------------------------------------------------------

select incident_id,crime_type,district,city,state,address,latitude,longitude,incident_datetime,officer_id,count(*) 
from crime_inc
group by incident_id,crime_type,district,city,state,address,latitude,longitude,incident_datetime,officer_id  
having count(*)>1 
order by incident_id;


-- ============================================================
-- 2.5 STANDARDIZATION OF CATEGORICAL COLUMNS
-- ============================================================


-- ------------------------------------------------------------
-- 2.5.1 STANDARDIZING CRIME TYPE
-- Reviewing inconsistent crime labels and mapping similar values
-- into a common standardized category for analysis.
-- ------------------------------------------------------------

select  crime_type,count(*) from crime_inc group by crime_type having count(*)>1 ;

update crime_inc set crime_type='kidnapping' where  crime_type like '%kidnap%' or crime_type='Abduction';
update crime_inc set crime_type='fraud' where  crime_type like '%Fraud%' or crime_type IN ('Scam','Deception');
update crime_inc set crime_type='drugs' where  crime_type like '%dru%' or crime_type='Narcotics';
update crime_inc set crime_type='cyber crime' where  crime_type like '%cyber%' or crime_type='Hacking';
update crime_inc set crime_type='graffiti' where  crime_type like '%graf%';
update crime_inc set crime_type='stealing' where  crime_type like '%steal%';
update crime_inc set crime_type='B&E' where  crime_type like '%B&E%' or crime_type like '%Breaking%';
update crime_inc set crime_type='theft' where  crime_type like '%theft%' or crime_type='Larceny';
update crime_inc set crime_type='burglary' where  crime_type like '%burg%';
update crime_inc set crime_type='robbery' where  crime_type like '%rob%';
update crime_inc set crime_type='homicide' where  crime_type like '%hom%' or crime_type IN ('Murder','manslaughter');
update crime_inc set crime_type='vandalism' where  crime_type like '%van%' or crime_type='Property Damage';
update crime_inc set crime_type='sexual assault' where  crime_type like '%ass%';
update crime_inc set crime_type='DWI' where  crime_type like '%D.U.I%' OR crime_type like '%D.U.I.%' OR crime_type like '%DUI%' OR crime_type like '%bui%' or crime_type IN ('Drunk Driving','D.U.I.');
update crime_inc set crime_type='domestic violence' where  crime_type like '%dom%' or crime_type='DV';
update crime_inc set crime_type='arson' where  crime_type like '%ars%';


-- ------------------------------------------------------------
-- 2.5.2 STANDARDIZING DISTRICT
-- Cleaning inconsistent district spellings/abbreviations and
-- converting district values into a common standard format.
-- ------------------------------------------------------------

select  district,count(*) from crime_inc group by district having count(*)>1 ;

update crime_inc set district='north' where  district like '%nor%';
update crime_inc set district='south' where  district like '%sou%';
update crime_inc set district='east' where  district like 'east%' OR district like 'EAS%';
update crime_inc set district='west' where  district like 'west%' or district like 'WES%';
update crime_inc set district='central' where  district like '%cen%';
update crime_inc set district='midtown' where  district like '%mid%';
update crime_inc set district=trim(district) ;
update crime_inc set district=upper(DISTRICT) ;


-- ============================================================
-- 2.6 DATETIME CLEANING AND CONVERSION
-- Standardizing incident_datetime values by identifying format
-- differences, converting them into proper DATETIME values, and
-- replacing the original text-based datetime column.
-- ============================================================

-- optional / avoid using if incident_datetime is still in mixed text format
-- alter table crime_inc modify incident_datetime date;

select incident_datetime,count(*) from crime_inc group by incident_datetime having count(*)>1 ;

update crime_inc set incident_datetime= null where incident_datetime='';

-- Checking the different date formats present in incident_datetime
SELECT
CASE
    WHEN incident_datetime LIKE '%/%' THEN 'slash format'
    WHEN incident_datetime LIKE '%-%' THEN 'hyphen format'
    ELSE 'other'
END AS format_type,
COUNT(*)
FROM crime_inc
GROUP BY format_type;

-- Adding a new column to store converted datetime values
alter table crime_inc add column new_datetime datetime;

-- Converting multiple datetime formats into a single standard DATETIME format
update crime_inc set new_datetime=
case
	when incident_datetime like '%/%' then STR_TO_DATE(incident_datetime ,'%m/%d/%Y %H:%i')
    when incident_datetime like '%-%' then STR_TO_DATE(incident_datetime ,'%d-%m-%Y') 
    else null
end;

-- Validation check: identify rows where original datetime existed but conversion failed
/* select count(*)
from crime_inc
where incident_datetime is not null
and new_datetime is null; */  

-- Replacing original incident_datetime column with cleaned datetime column
alter table crime_inc drop column incident_datetime;
show columns from crime_inc;
alter table crime_inc change column new_datetime incident_datetime datetime; 


-- ============================================================
-- 2.7 GEOGRAPHIC COORDINATE VALIDATION
-- Validating latitude and longitude ranges and replacing invalid
-- values with NULL to avoid incorrect geographic analysis.
-- ============================================================

SELECT COUNT(*)
FROM crime_inc
WHERE latitude NOT BETWEEN -90 AND 90
   OR longitude NOT BETWEEN -180 AND 180;
   
UPDATE crime_inc
SET latitude = NULL
WHERE latitude NOT BETWEEN -90 AND 90;

UPDATE crime_inc
SET longitude = NULL
WHERE longitude NOT BETWEEN -180 AND 180;

UPDATE crime_inc
SET longitude = NULL
WHERE latitude IS NULL;

-- Validated geographic coordinates against accepted latitude (-90 to 90) and longitude (-180 to 180) ranges.
-- Identified invalid coordinate values and replaced them with NULL to ensure accurate geographic analysis.
