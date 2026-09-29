-- ============================================================
-- 1. DATABASE SETUP AND RAW DATA BACKUP
-- ============================================================

create database pro_crimes;
use pro_crimes;

-- importing data
-- database_name -> right click -> table import data wizard -> follow steps to import data

-- creating table to save original/raw backup data
create table crimes_dataset as
select * from crime_incidents;