-- STEP 1: Removing rows with NULLs in key columns
CREATE OR REPLACE TABLE `olist-analysis-465402.Olist_dataset.order_reviews_step1_no_nulls` AS
SELECT *
FROM `olist-analysis-465402.Olist_dataset.order_reviews`
WHERE 
  review_id IS NOT NULL
  AND order_id IS NOT NULL
  AND review_score IS NOT NULL
  AND review_creation_date IS NOT NULL
  AND review_answer_timestamp IS NOT NULL;

-- STEP 2: Validating date logic
-- Making sure review was answered at or after it was created
CREATE OR REPLACE TABLE `olist-analysis-465402.Olist_dataset.order_reviews_step2_valid_dates` AS
SELECT *
FROM `olist-analysis-465402.Olist_dataset.order_reviews_step1_no_nulls`
WHERE review_answer_timestamp >= TIMESTAMP(review_creation_date);

-- STEP 3: Removing duplicate review_ids
-- Keeping only the latest one based on review_answer_timestamp
CREATE OR REPLACE TABLE `olist-analysis-465402.Olist_dataset.order_reviews_step3_no_duplicates` AS
SELECT *
FROM (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY review_id ORDER BY review_answer_timestamp DESC) AS row_num
  FROM `olist-analysis-465402.Olist_dataset.order_reviews_step2_valid_dates`
)
WHERE row_num = 1;

-- STEP 4: saving clean table
CREATE OR REPLACE TABLE `olist-analysis-465402.Olist_dataset.order_reviews_clean_final` AS
SELECT
  review_id,
  order_id,
  review_score,
  review_creation_date,
  review_answer_timestamp
FROM `olist-analysis-465402.Olist_dataset.order_reviews_step3_no_duplicates`;



DROP TABLE IF EXISTS `olist-analysis-465402.Olist_dataset.order_reviews_step1_no_nulls`;
DROP TABLE IF EXISTS `olist-analysis-465402.Olist_dataset.order_reviews_step2_valid_dates`;
DROP TABLE IF EXISTS `olist-analysis-465402.Olist_dataset.order_reviews_step3_no_duplicates`;