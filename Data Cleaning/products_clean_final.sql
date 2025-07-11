-- STEP 1: Removing rows with NULLs in key columns
-- We're keeping only rows that have a product_id and product_category_name.

CREATE OR REPLACE TABLE `olist-analysis-465402.Olist_dataset.products_step1_no_nulls` AS
SELECT *
FROM `olist-analysis-465402.Olist_dataset.products`
WHERE 
  product_id IS NOT NULL
  AND product_category_name IS NOT NULL;

-- STEP 2: Normalize product category text
-- We'll make category names lowercase and remove extra whitespace.

CREATE OR REPLACE TABLE `olist-analysis-465402.Olist_dataset.products_step2_normalized_category` AS
SELECT
  *,
  LOWER(TRIM(product_category_name)) AS cleaned_category
FROM `olist-analysis-465402.Olist_dataset.products_step1_no_nulls`;

-- STEP 3: Filtering invalid or missing weight/dimensions
-- We'll remove rows where any of these values are 0 or NULL: weight, height, length, width

CREATE OR REPLACE TABLE `olist-analysis-465402.Olist_dataset.products_step3_valid_dimensions` AS
SELECT *
FROM `olist-analysis-465402.Olist_dataset.products_step2_normalized_category`
WHERE 
  product_weight_g IS NOT NULL AND product_weight_g > 0
  AND product_length_cm IS NOT NULL AND product_length_cm > 0
  AND product_height_cm IS NOT NULL AND product_height_cm > 0
  AND product_width_cm IS NOT NULL AND product_width_cm > 0;


-- STEP 4: Removing duplicate product_id entries
-- If duplicates exist, we’ll keep only the first one based on the longest product name.

CREATE OR REPLACE TABLE `olist-analysis-465402.Olist_dataset.products_step4_no_duplicates` AS
SELECT *
FROM (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY product_name_lenght DESC) AS row_num
  FROM `olist-analysis-465402.Olist_dataset.products_step3_valid_dimensions`
)
WHERE row_num = 1;


-- STEP 5: Saving the final cleaned table


CREATE OR REPLACE TABLE `olist-analysis-465402.Olist_dataset.products_clean_final` AS
SELECT
  product_id,
  cleaned_category AS product_category_name,
  product_name_lenght,
  product_description_lenght,
  product_photos_qty,
  product_weight_g,
  product_length_cm,
  product_height_cm,
  product_width_cm
FROM `olist-analysis-465402.Olist_dataset.products_step4_no_duplicates`;




DROP TABLE `olist-analysis-465402.Olist_dataset.products_step1_no_nulls`;
DROP TABLE `olist-analysis-465402.Olist_dataset.products_step2_normalized_category`;
DROP TABLE `olist-analysis-465402.Olist_dataset.products_step3_valid_dimensions`;
DROP TABLE `olist-analysis-465402.Olist_dataset.products_step4_no_duplicates`;

