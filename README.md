# Data Normalization

This is data management activity of New York University's `Data Management and Analysis (CSCI-UA 479)` class.

## Table of Contents

- [File Directory](#file-directory)
- [Inspecting nation_subset data](#inspecting-nation-subset-data)
  - [Create an ER Diagram by inspecting tables](#create-an-er-diagram-by-inspecting-tables)
- [Inspecting CAERS dataset](#inspecting-caers-dataset)
  - [Examine a data set and create a normalized data model to store the data](#examine-a-data-set-and-create-a-normalized-data-model-to-store-the-data)
  - [Data normalization and ER diagram](#data-normalization-and-er-diagram)

## File Directory

```bash
├── data
│   ├── nation_subset.sql
│		├── CAERS-Quarterly--20220930-EXCEL.csv
├── src
│ 	├── nation_subset_analysis.sql					#Analyze nation_subset data
│   ├── create_staging_t.sql								#Create table for CAERS events
│   ├── caers_event_data_import.sql					#Add actual data to the tables
│   ├── staging_table_analysis.sql					#Analyze caers event data for normalization
│   ├── normalization_t_ddl.sql							#Create table to implement the data model
└── README.md
```

## Inspecting nation_subset data

### Create an ER Diagram by inspecting tables

Create ER Diagram based on tables in SQL file - `nation_subset.sql`.

![nation_subset_er_diagram](https://github.com/seoeunHong/data-normalization/assets/75988952/1be6f893-0c2c-466e-9211-01ca7bdc6514)

`nation_subset.sql` contains information about countries (such as population, languages, etc.). This data is sourced from a site for another relational database (https://www.mariadbtutorial.com/), so the import statements have been adapted to postgres. The data is contained in multiple tables.

`continents`

- It has a one-to-many relationship with `regions`. This relationship exists because of a foreign key `continent_id` in `regions` that references `continents(continent_id)`

`countries`

- It has a one-to-many relationship with `regions`. This relationship exists because of a foreign key `region_id` in `countries` that references `regions(region_id)`
- It has a one-to-many relationship with `country_languages`. this relationship exists because of a foreign key `country_id` in `country_languages` that references `countries(country_id)`
- It has a one-to-many relationship with `country_stats`. This relationship exists because of a foreign key `country_id` in `country_stats` that references `countries(country_id)`
- It has a many-to-many relationship with `languages`. This relationship exists because third table `country_languages` references  both primary keys `countries(country_id)`  and `languages(language_id)`as its foreign keys.

`country_languages`

- It has a one-to-many relationship with `countries`. this relationship exists because of a foreign key `country_id` in `country_languages` that references `countries(country_id)`
- It has a one-to-many relationship with `languages`. this relationship exists because of a foreign key `language_id` in `country_languages` that references `languages(language_id)`

`country_stats`

- It has a one-to-many relationship with `countries`. This relationship exists because of a foreign key `country_id` in `country_stats` that references `countries(country_id)`

`languages`

- It has a one-to-many relationship with `country_loanguages`. This relationship exists because of a foreign key `language_id` in `country_languages` that references `languages(language_id)`
- It has a many-to-many relationship with `countries`. This relationship exists because third table `country_languages` references  both primary keys `countries(country_id)`  and `languages(language_id)`as its foreign keys.

`region_areas`

`regions`

- It has a one-to-many relationship with `continents`. This relationship exists because of a foreign key `continent_id` in `regions` that references `continents(continent_id)`
- It has a one-to-many relationship with `countries`. This relationship exists because of a foreign key `region_id` in `countries` that references `regions(region_id)`

## Inspecting CAERS dataset

### Examine a data set and create a normalized data model to store the data

Create table for the data sourced from [FDA CAERS website](https://www.fda.gov/food/compliance-enforcement-food/cfsan-adverse-event-reporting-system-caers), and examine dataset using PostgreSQL for normalization.

(All related SQL files are in `src` folder)

```postgresql
-- 1. Thie query tries to determine whether or not report id is unique

SELECT
  report_id,
  count(*) as report_id_count
FROM staging_caers_event_product
GROUP BY report_id
HAVING count(*) > 1
ORDER BY report_id_count DESC
LIMIT 5;

-- report_id | report_id_count 
-------------+-----------------
-- 179852    |              44
-- 174049    |              39
-- 117851    |              39
-- 141218    |              36
-- 210074    |              35
--(5 rows)

-- Based on the output, report_id cannot be a primary key because value is not unique.
```

```postgresql

-- 2. This query check whether we have duplicate rows or not

SELECT fda_first_received_report_date, report_id, 
event_date, product_type, product, product_code, 
description, patient_age, age_units, sex, 
case_meddra_preferred_terms, case_outcome, COUNT(*) as duplicates_count
FROM staging_caers_event_product
GROUP BY fda_first_received_report_date, report_id, 
event_date, product_type, product, product_code, 
description, patient_age, age_units, sex, 
case_meddra_preferred_terms, case_outcome
HAVING COUNT(*) > 1
LIMIT 5;

-- fda_first_received_report_date | report_id | event_date | product_type |    product     | product_code |              description               | patient_age | age_units |  sex   |                                                                           case_meddra_preferred_terms                                                                           |                                   case_outcome                                   | duplicates_count 
----------------------------------+-----------+------------+--------------+----------------+--------------+----------------------------------------+-------------+-----------+--------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------------------------------------------------------------------------+------------------
-- 2004-01-22                     | 65952     |            | SUSPECT      | EXEMPTION 4    | 54           | Vit/Min/Prot/Unconv Diet(Human/Animal) |       60.00 | year(s)   | Female | ABDOMINAL PAIN, COUGH, FATIGUE, FIBROMYALGIA, HEADACHE, IMMUNE SYSTEM DISORDER, IRRITABLE BOWEL SYNDROME, JOINT SWELLING, RASH                                                  | Visited a Health Care Provider                                                   |                2
-- 2004-03-12                     | 70661     |            | SUSPECT      | EXEMPTION 4    | 53           | Cosmetics                              |             |           | Female | BLISTER, SWELLING                                                                                                                                                               | Visited a Health Care Provider                                                   |                2
-- 2004-04-13                     | 68138     |            | SUSPECT      | EXEMPTION 4    | 53           | Cosmetics                              |       32.00 | year(s)   | Female | BURNING SENSATION, HYPERSENSITIVITY, INFECTION, PRURITUS, SECRETION DISCHARGE, SWELLING                                                                                         | Visited a Health Care Provider                                                   |                5
-- 2004-05-21                     | 69134     | 1999-08-01 | SUSPECT      | EXEMPTION 4    | 54           | Vit/Min/Prot/Unconv Diet(Human/Animal) |       51.00 | year(s)   | Female | ALANINE AMINOTRANSFERASE INCREASED, ASPARTATE AMINOTRANSFERASE INCREASED, BLOOD ALKALINE PHOSPHATASE INCREASED, GAMMA-GLUTAMYLTRANSFERASE INCREASED, HEPATITIS, HOSPITALISATION | Hospitalization, Other Serious or Important Medical Event, Other Serious Outcome |                2
-- 2004-06-09                     | 69634     |            | CONCOMITANT  | FRUIT SMOOTHIE | 09           | Milk/Butter/Dried Milk Prod            |             |           | Female | HEADACHE, VOMITING                                                                                                                                                              | Other Outcome                                                                    |                2
--(5 rows)

-- Based on the output, we have duplicate rows in table. Therefore, our table currently does not satisfy 1NF.

```

```postgresql
-- 3. To satisfy 1NF, we need to drop duplicate rows This query delete duplicate rows from the table

CREATE OR REPLACE VIEW staging_caers_event_product_view AS
SELECT DISTINCT fda_first_received_report_date, report_id, 
event_date, product_type, product, product_code, 
description, patient_age, age_units, sex, 
case_meddra_preferred_terms, case_outcome
FROM staging_caers_event_product;

-- CREATE VIEW

-- Based on the output, we successfully extract unique rows from our table and saved them as a view.
```

```postgresql

-- 4. Find candidate keys by adding new columns until there are no duplicates
SELECT report_id, product_type, product, product_code, COUNT(*) AS duplicates_count
FROM staging_caers_event_product_view
GROUP BY report_id, product_type, product, product_code
HAVING COUNT(*) > 1
LIMIT 5;

-- report_id | product_type | product | product_code | duplicates_count 
-------------+--------------+---------+--------------+------------------
--(0 rows)

-- Based on the output, our possible candidate key column combinations are report_id, product_type, product, and product_code because with this composite columns, we can identify unique rows
```

```postgresql
-- 5. This query check functional dependency between product_code and description
SELECT product_code, COUNT(*) AS count
FROM(
	SELECT DISTINCT product_code, description
	FROM staging_caers_event_product_view
) tmp
GROUP BY product_code
ORDER BY count DESC
LIMIT 5;

-- product_code | count 
----------------+-------
-- 34           |     1
-- 18           |     1
-- 32           |     1
-- 37           |     1
-- 13           |     1
--(5 rows)

-- Based on the output, description is functionally dependent on product_code because only unique description value is associated with unique product_code
```

```postgresql
-- 5. Check partial key dependency between composite keys
SELECT product, COUNT(*) AS count
FROM(
    SELECT DISTINCT product, product_code
    FROM staging_caers_event_product_view
) tmp
GROUP BY product
ORDER BY count DESC
LIMIT 5;

--         product         | count 
---------------------------+-------
-- EXEMPTION 4             |    40
-- SALAD                   |     5
-- TURMERIC                |     4
-- JIF PEANUT BUTTER       |     4
-- DAILY HARVEST SMOOTHIES |     4
--(5 rows)

-- Based on this output, the product column is not functionally dependent on the product_code column because many products are associated with same product_code.
```

```postgresql
-- 6. Column "case_meddra_preferred_terms" is not atomic.
-- This query check all distinct terms in "case_meddra_preferred_terms" column
SELECT DISTINCT unnest(string_to_array(case_meddra_preferred_terms, ', ')) AS preferred_term
FROM staging_caers_event_product_view
LIMIT 5;

--     preferred_term     
--------------------------
-- Abortion threatened
-- KAWASAKI'S DISEASE
-- BONE CANCER METASTATIC
-- EMBOLISM
-- URINE ANALYSIS
--(5 rows)

-- Based on the output, we should make seperate table for prefereed term with these distinct values.
```

```postgresql
-- 7. Column "case_outcome" is not atomic.
-- This query check all distinct terms in "case_outcome" column
SELECT DISTINCT unnest(string_to_array(case_outcome, ', ')) AS outcome
FROM staging_caers_event_product_view;

--                 outcome                  
--------------------------------------------
-- Other Serious Outcome
-- Death
-- Injury
-- Visited Emergency Room
-- Life Threatening
-- Required Intervention
-- Visited a Health Care Provider
-- Other Serious or Important Medical Event
-- Other Outcome
-- Hospitalization
-- Disability
-- Allergic Reaction
-- Congenital Anomaly
--(13 rows)

-- Based on the output, we should make seperate table for prefereed term with these distinct values.

```

```postgresql
-- 8. To optimize our database storage, check the max lengths for each cols
SELECT MAX(char_length(report_id)) FROM staging_caers_event_product_view; --  15
SELECT MAX(char_length(product_type)) FROM staging_caers_event_product_view; --  11
SELECT MAX(char_length(product)) FROM staging_caers_event_product_view; -- 200
SELECT MAX(char_length(product_code)) FROM staging_caers_event_product_view; -- 3
SELECT MAX(char_length(description)) FROM staging_caers_event_product_view; --  44
SELECT MAX(char_length(age_units)) FROM staging_caers_event_product_view; --   9
SELECT MAX(char_length(sex)) FROM staging_caers_event_product_view; --  12

-- Based on the output, we can save each columns - report_id, product_type, product, product_code, description, age_units, sex - into each max length varcahr.
```

### Data normalization and ER diagram

![part3_03_caers_er_diagram](https://user-images.githubusercontent.com/75988952/231681465-21abbbcb-6637-4479-b97d-fadd6deb82a1.jpeg)

`caers_case`

-  I made one caers case with column report_id, fda_first_received_report_date, event_date. I didn't use the first candidate key that I first assumed because I wanted to have seperate table for `product` because unique `product`  can be associated with many `caers_case`, so that we can save database storage. For same reason, I wanted to seperate `patient` too from `caers_case`. In addition to this, I needed to seperate `case_meddra_preferred_terms` and `case_outcome` column because those two columns have multiple values. Therefore, I only kept `report_id`, `fda_first_received_report_date`, and `event_date` from original data and insert `patient_id` and `product_id` for table relation and added `id` for primary key

`product`

- I made seperate table for product. This table contains all information for product. Add `product_id` for primary key and set `product_code` as foreign key for one-to-one table relationship with `product_description`

`product_description`

- I made seperate table for `product_code` and `description` because I noticed they are functionally dependet. Set `product_code` as primary key. 

`patient_info`

- I made seperate table for patient. `patient_age` and `age_units` can be combined together into `age` by calculation with query, so I added `age` instead of two columns and add `patient_id` as primary key.

`case_terms`

- I made join table for `caers_case` and `terms` for seperate multiple values in `case_meddra_preferred_terms` column. Set `id` and `term_id` as foreign key for table relation

`terms`

- I made seperate table for each unique values in `case_meddra_preferred_terms` column and connect with `caers_case` many-to-many relation with using join table `case_term`

`case_outcomes`

- I made join table for `caers_case` and `outcomes` for seperate multiple values in `case_outcome` column. Set `id` and `outcome_id` as foreign key for table relation

`outcomes`

- I made seperate table for each unique values in `case_outcome` column and connect with `caers_case` many-to-many relation with using join table `case_outcomes`
