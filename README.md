# Crime Incident Data Analysis using SQL

## Project Overview
This project analyzes a crime incidents dataset using SQL, with a complete workflow covering **database setup, data cleaning, data validation, and exploratory analysis**. The objective was not only to write analysis queries, but also to prepare messy raw data for reliable reporting by handling duplicates, inconsistent category values, mixed date formats, and invalid geographic coordinates.

The project was built in **MySQL Workbench** and organized into separate SQL modules to reflect a structured data analysis workflow.

---

## Objective
The goal of this project was to transform raw crime incident data into an analysis-ready dataset and use SQL to answer questions related to:

- crime distribution across categories
- crime patterns across cities and districts
- time-based crime trends
- officer workload
- ranking of crime categories by incident volume

---

## Tools and SQL Skills Used

### Tools
- **MySQL Workbench**
- **SQL**

### SQL Skills Demonstrated
- Database creation and table management
- Data cleaning using `UPDATE`, `DELETE`, and `ALTER TABLE`
- Duplicate detection using `ROW_NUMBER()`
- Data validation using null, blank, and range checks
- Aggregate analysis using `COUNT()` and `AVG()`
- Common Table Expressions (**CTEs**)
- Window functions:
  - `ROW_NUMBER()`
  - `RANK()`
  - `DENSE_RANK()`
- Date and time functions:
  - `YEAR()`
  - `MONTHNAME()`
  - `HOUR()`
  - `STR_TO_DATE()`

---

## Project Workflow

### 1) Database Setup and Raw Data Backup
- Created a database named **`pro_crimes`**
- Imported the raw crime incidents dataset
- Created a backup copy of the original imported data for reference

### 2) Data Cleaning
The dataset was cleaned and standardized before analysis. Key cleaning tasks included:

- detecting duplicate records
- removing duplicate rows using `ROW_NUMBER()`
- standardizing inconsistent values in the **crime_type** column
- standardizing district names
- converting mixed date formats into a proper datetime format
- validating latitude and longitude values
- replacing invalid coordinate values with `NULL` where necessary

### 3) Data Validation
After cleaning, validation checks were performed to ensure data quality, including:

- duplicate re-check after cleaning
- null value checks across key columns
- blank text value checks
- invalid coordinate re-check
- coordinate consistency checks

### 4) Exploratory Data Analysis
SQL analysis queries were used to explore patterns in the cleaned dataset across:
- crime type
- city and district
- year, month, and hour
- officer workload
- crime ranking using window functions

---

## Key Analysis Questions
The project includes SQL queries to answer questions such as:

- Which crime types are reported most and least frequently?
- Which cities and districts have the highest number of incidents?
- What is the most common and least common crime type in each city and district?
- How do crime incidents vary by year, month, and hour of the day?
- Which hour has the highest number of reported crimes?
- How many cases has each officer handled?
- How do crime categories rank by total incident volume?

---

## Key Insights
This SQL project enables the following analysis and findings from the cleaned crime dataset:

- comparison of crime volume across different **crime categories**
- identification of the **most and least frequently reported crimes**
- identification of **high-crime cities and districts**
- comparison of the **most common and least common crime types** within each city and district
- analysis of crime occurrence by **year, month, and hour**
- identification of the **hour with the highest crime activity**
- officer workload analysis based on the **number of incidents handled**
- ranking of crime categories using **window functions** for comparative analysis

---

## Project Files

### `database_creation_setup_importing_data.sql`
Contains database creation, database selection, dataset import note, and creation of a raw backup table.

### `data_cleaning.sql`
Contains duplicate handling, crime type standardization, district standardization, datetime conversion, and coordinate cleaning.

### `validating_data.sql`
Contains post-cleaning duplicate checks, null checks, blank value checks, and coordinate validation checks.

### `exploratory_file.sql`
Contains SQL analysis queries for crime distribution, location-based analysis, time-based analysis, officer workload analysis, and ranking analysis.

---

## Project Structure

```text
crimes_sql_project/
│
├── crime_incidents_dataset.csv
├── database_creation_setup_importing_data.sql
├── data_cleaning.sql
├── validating_data.sql
├──analysisqueries.sql
└── README.md