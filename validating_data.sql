

-- ============================================================
-- 3. POST-CLEANING DATA VALIDATION
-- Running final checks to confirm that the cleaned dataset is
-- free from duplicates, major null issues, blank strings, and
-- invalid coordinate inconsistencies.
-- ============================================================


-- ------------------------------------------------------------
-- 3.1 FINAL DUPLICATE RECHECK
-- Ensures no duplicate records remain in the cleaned dataset.
-- ------------------------------------------------------------

SELECT incident_id,crime_type,district,city,state,address,
       latitude,longitude,incident_datetime,officer_id,
       COUNT(*)
FROM crime_inc
GROUP BY incident_id,crime_type,district,city,state,address,
         latitude,longitude,incident_datetime,officer_id
HAVING COUNT(*) > 1;


-- ------------------------------------------------------------
-- 3.2 NULL VALUE SUMMARY
-- Counts null values in all major columns after cleaning.
-- ------------------------------------------------------------

SELECT
SUM(incident_id IS NULL) AS incident_id_nulls,
SUM(crime_type IS NULL) AS crime_type_nulls,
SUM(district IS NULL) AS district_nulls,
SUM(city IS NULL) AS city_nulls,
SUM(state IS NULL) AS state_nulls,
SUM(address IS NULL) AS address_nulls,
SUM(latitude IS NULL) AS latitude_nulls,
SUM(longitude IS NULL) AS longitude_nulls,
SUM(incident_datetime IS NULL) AS datetime_nulls,
SUM(officer_id IS NULL) AS officer_id_nulls
FROM crime_inc;


-- ------------------------------------------------------------
-- 3.3 BLANK STRING CHECK
-- Detecting empty strings in important text columns after cleaning.
-- ------------------------------------------------------------

SELECT *
FROM crime_inc
WHERE TRIM(crime_type)=''
   OR TRIM(district)=''
   OR TRIM(city)=''
   OR TRIM(state)=''
   OR TRIM(address)='';


-- ------------------------------------------------------------
-- 3.4 INVALID COORDINATE RANGE RECHECK
-- Verifies that no remaining latitude/longitude values fall
-- outside valid geographic ranges.
-- ------------------------------------------------------------

SELECT count(*)
FROM crime_inc
WHERE latitude NOT BETWEEN -90 AND 90
   OR longitude NOT BETWEEN -180 AND 180; 


-- ------------------------------------------------------------
-- 3.5 COORDINATE CONSISTENCY CHECK
-- Checks for rows where only one of latitude/longitude exists,
-- which may indicate incomplete location information.
-- ------------------------------------------------------------

SELECT COUNT(*)
FROM crime_inc
WHERE (latitude IS NULL AND longitude IS NOT NULL)
   OR (latitude IS NOT NULL AND longitude IS NULL);