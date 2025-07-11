-- STEP 1: Removing rows with NULLs in key columns
-- We’ll make sure every seller has an ID, zip code, city, and state.

CREATE OR REPLACE TABLE `olist-analysis-465402.Olist_dataset.sellers_step1_no_nulls` AS
SELECT *
FROM `olist-analysis-465402.Olist_dataset.sellers`
WHERE 
  seller_id IS NOT NULL
  AND seller_zip_code_prefix IS NOT NULL
  AND seller_city IS NOT NULL
  AND seller_state IS NOT NULL;

-- STEP 2: Normalizing text fields
-- Converting city and state names to lowercase, and trimming extra spaces.

CREATE OR REPLACE TABLE `olist-analysis-465402.Olist_dataset.sellers_step2_normalized_text` AS
SELECT
  seller_id,
  seller_zip_code_prefix,
  LOWER(TRIM(seller_city)) AS seller_city,
  LOWER(TRIM(seller_state)) AS seller_state
FROM `olist-analysis-465402.Olist_dataset.sellers_step1_no_nulls`;

-- STEP 3: Validating ZIP code
-- Removing rows where the ZIP code isn't numeric or is suspiciously short (< 3 digits)

CREATE OR REPLACE TABLE `olist-analysis-465402.Olist_dataset.sellers_step3_valid_zip` AS
SELECT *
FROM `olist-analysis-465402.Olist_dataset.sellers_step2_normalized_text`
WHERE 
  REGEXP_CONTAINS(CAST(seller_zip_code_prefix AS STRING), r'^\d+$')
  AND LENGTH(CAST(seller_zip_code_prefix AS STRING)) >= 3;

-- STEP 4: Removing duplicates
-- If any seller_id appears more than once, we’ll keep only the first one.

CREATE OR REPLACE TABLE `olist-analysis-465402.Olist_dataset.sellers_step4_no_duplicates` AS
SELECT *
FROM (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY seller_id ORDER BY seller_zip_code_prefix) AS row_num
  FROM `olist-analysis-465402.Olist_dataset.sellers_step3_valid_zip`
)
WHERE row_num = 1;

-- STEP 5: Saving the final cleaned table

CREATE OR REPLACE TABLE `olist-analysis-465402.Olist_dataset.sellers_clean_final` AS
SELECT
  seller_id,
  seller_zip_code_prefix,
  seller_city,
  seller_state
FROM `olist-analysis-465402.Olist_dataset.sellers_step4_no_duplicates`;




DROP TABLE `olist-analysis-465402.Olist_dataset.sellers_step1_no_nulls`;
DROP TABLE `olist-analysis-465402.Olist_dataset.sellers_step2_normalized_text`;
DROP TABLE `olist-analysis-465402.Olist_dataset.sellers_step3_valid_zip`;
DROP TABLE `olist-analysis-465402.Olist_dataset.sellers_step4_no_duplicates`;
