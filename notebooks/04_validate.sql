-- Databricks notebook source
-- MAGIC %md
-- MAGIC # 04. 파이프라인 및 지표 검증
-- MAGIC
-- MAGIC 강사가 실행 결과를 확인하는 체크 노트북입니다.

-- COMMAND ----------

SELECT 'bronze_orders' AS object_name, COUNT(*) AS actual, 300 AS expected
FROM cafe_training.cafe_hands_on.bronze_orders
UNION ALL
SELECT 'silver_orders_clean', COUNT(*), 296
FROM cafe_training.cafe_hands_on.silver_orders_clean
UNION ALL
SELECT 'gold_sales', COUNT(*), 266
FROM cafe_training.cafe_hands_on.gold_sales;

-- COMMAND ----------

SELECT
  MEASURE(gross_sales) AS gross_sales,
  MEASURE(discount_amount) AS discount_amount,
  MEASURE(net_sales) AS net_sales,
  MEASURE(order_count) AS order_count,
  MEASURE(item_quantity) AS item_quantity,
  MEASURE(avg_order_value) AS avg_order_value
FROM cafe_training.cafe_hands_on.cafe_sales_metrics;

-- 기대값:
-- gross_sales     = 1,772,800
-- discount_amount =    38,220
-- net_sales       = 1,734,580
-- order_count     =       266
-- item_quantity   =       356
-- avg_order_value =  6,520.98

-- COMMAND ----------

SELECT
  store_name,
  MEASURE(net_sales) AS net_sales
FROM cafe_training.cafe_hands_on.cafe_sales_metrics
GROUP BY store_name
ORDER BY net_sales DESC;

-- 기대값:
-- 판교점   647,460
-- 강남점   573,500
-- 해운대점 513,620

-- COMMAND ----------

SELECT
  product_name,
  MEASURE(item_quantity) AS item_quantity,
  MEASURE(net_sales) AS net_sales
FROM cafe_training.cafe_hands_on.cafe_sales_metrics
GROUP BY product_name
ORDER BY item_quantity DESC
LIMIT 5;
