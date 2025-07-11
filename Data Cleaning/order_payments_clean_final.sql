-- STEP 1: Removing rows with NULLs in important columns
-- We'll drop any rows that are missing order_id, payment_type, or payment_value,
-- because they are essential for payment tracking.
CREATE OR REPLACE TABLE `olist-analysis-465402.Olist_dataset.order_payments_step1_no_nulls` AS
SELECT *
FROM `olist-analysis-465402.Olist_dataset.order_payments`
WHERE 
  order_id IS NOT NULL
  AND payment_type IS NOT NULL
  AND payment_value IS NOT NULL;

-- STEP 2: Normalizing text fields
-- Clean up payment_type by trimming and converting to lowercase
CREATE OR REPLACE TABLE `olist-analysis-465402.Olist_dataset.order_payments_step2_normalized` AS
SELECT 
  order_id,
  payment_sequential,
  LOWER(TRIM(payment_type)) AS cleaned_payment_type,
  payment_installments,
  payment_value
FROM `olist-analysis-465402.Olist_dataset.order_payments_step1_no_nulls`;

-- STEP 3: Validating data ranges
-- Check for logical values: e.g., payment_value > 0, installments ≥ 1
CREATE OR REPLACE TABLE `olist-analysis-465402.Olist_dataset.order_payments_step3_validated` AS
SELECT *
FROM `olist-analysis-465402.Olist_dataset.order_payments_step2_normalized`
WHERE 
  payment_value > 0
  AND payment_installments >= 1;

-- STEP 4: Removing exact duplicates (if any)
CREATE OR REPLACE TABLE `olist-analysis-465402.Olist_dataset.order_payments_step4_deduped` AS
SELECT DISTINCT *
FROM `olist-analysis-465402.Olist_dataset.order_payments_step3_validated`;

-- STEP 5: Saving final cleaned table
CREATE OR REPLACE TABLE `olist-analysis-465402.Olist_dataset.order_payments_clean_final` AS
SELECT 
  order_id,
  payment_sequential,
  cleaned_payment_type AS payment_type,
  payment_installments,
  payment_value
FROM `olist-analysis-465402.Olist_dataset.order_payments_step4_deduped`;




DROP TABLE IF EXISTS `olist-analysis-465402.Olist_dataset.order_payments_step1_no_nulls`;
DROP TABLE IF EXISTS `olist-analysis-465402.Olist_dataset.order_payments_step2_normalized`;
DROP TABLE IF EXISTS `olist-analysis-465402.Olist_dataset.order_payments_step3_validated`;
DROP TABLE IF EXISTS `olist-analysis-465402.Olist_dataset.order_payments_step4_deduped`;
