-- Databricks notebook source
-- MAGIC %md
-- MAGIC # 02. Metric View 기준선 생성
-- MAGIC
-- MAGIC 설명·동의어·포맷·Materialization을 넣기 전 기준선입니다.
-- MAGIC 이 상태에서 Genie 벤치마크를 먼저 실행한 뒤 최적화 버전과 비교합니다.

-- COMMAND ----------

CREATE OR REPLACE VIEW cafe_training.cafe_hands_on.cafe_sales_metrics
WITH METRICS
LANGUAGE YAML
AS
$$
version: 1.1
source: cafe_training.cafe_hands_on.gold_sales
fields:
  - name: order_date
    expr: order_date
  - name: day_name
    expr: day_name
  - name: day_type
    expr: day_type
  - name: daypart
    expr: daypart
  - name: store_name
    expr: store_name
  - name: region
    expr: region
  - name: product_name
    expr: product_name
  - name: category
    expr: category
measures:
  - name: gross_sales
    expr: SUM(gross_sales)
  - name: discount_amount
    expr: SUM(discount_amount)
  - name: net_sales
    expr: SUM(net_sales)
  - name: order_count
    expr: COUNT(DISTINCT order_id)
  - name: item_quantity
    expr: SUM(quantity)
  - name: avg_order_value
    expr: SUM(net_sales) / COUNT(DISTINCT order_id)
$$;

-- COMMAND ----------

SELECT
  MEASURE(net_sales) AS net_sales,
  MEASURE(order_count) AS order_count,
  MEASURE(avg_order_value) AS avg_order_value
FROM cafe_training.cafe_hands_on.cafe_sales_metrics;
