-- Databricks notebook source
-- MAGIC %md
-- MAGIC # 01. 카페 메달리온 Lakeflow Pipeline
-- MAGIC
-- MAGIC 이 노트북은 일반 SQL 노트북이 아니라 **Lakeflow Spark Declarative Pipelines 소스**로 등록합니다.
-- MAGIC 한 파일 안에서 Bronze → Silver → Gold 의존성을 선언하면 Lakeflow가 DAG와 실행 순서를 자동 구성합니다.

-- COMMAND ----------

CREATE OR REFRESH STREAMING TABLE bronze_stores
COMMENT '원본 CSV를 변경 없이 증분 적재한 매장 Bronze 테이블'
TBLPROPERTIES ('quality' = 'bronze')
AS
SELECT
  *,
  _metadata.file_path AS _source_file,
  current_timestamp() AS _ingested_at
FROM STREAM read_files(
  -- Streaming read_files는 파일 경로 대신 디렉터리 또는 glob 경로를 사용합니다.
  '/Volumes/cafe_training/cafe_landing/raw/stores*.csv',
  format => 'csv',
  header => 'true',
  inferColumnTypes => 'false'
);

-- COMMAND ----------

CREATE OR REFRESH STREAMING TABLE bronze_products
COMMENT '원본 CSV를 변경 없이 증분 적재한 상품 Bronze 테이블'
TBLPROPERTIES ('quality' = 'bronze')
AS
SELECT
  *,
  _metadata.file_path AS _source_file,
  current_timestamp() AS _ingested_at
FROM STREAM read_files(
  -- Streaming read_files는 파일 경로 대신 디렉터리 또는 glob 경로를 사용합니다.
  '/Volumes/cafe_training/cafe_landing/raw/products*.csv',
  format => 'csv',
  header => 'true',
  inferColumnTypes => 'false'
);

-- COMMAND ----------

CREATE OR REFRESH STREAMING TABLE bronze_orders
COMMENT '3개 CSV 배치를 Auto Loader로 증분 적재한 주문 Bronze 테이블'
TBLPROPERTIES ('quality' = 'bronze')
AS
SELECT
  *,
  _metadata.file_path AS _source_file,
  current_timestamp() AS _ingested_at
FROM STREAM read_files(
  '/Volumes/cafe_training/cafe_landing/raw/orders',
  format => 'csv',
  header => 'true',
  inferColumnTypes => 'false'
);

-- COMMAND ----------

CREATE OR REFRESH MATERIALIZED VIEW silver_stores (
  CONSTRAINT valid_store_id EXPECT (store_id IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT valid_store_name EXPECT (store_name IS NOT NULL) ON VIOLATION DROP ROW
)
COMMENT '타입과 필수값을 정리한 매장 Silver 테이블'
TBLPROPERTIES ('quality' = 'silver')
AS
SELECT
  TRIM(store_id) AS store_id,
  TRIM(store_name) AS store_name,
  TRIM(region) AS region,
  TRY_CAST(opened_date AS DATE) AS opened_date
FROM bronze_stores;

-- COMMAND ----------

CREATE OR REFRESH MATERIALIZED VIEW silver_products (
  CONSTRAINT valid_product_id EXPECT (product_id IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT positive_list_price EXPECT (list_price > 0) ON VIOLATION DROP ROW
)
COMMENT '타입과 필수값을 정리한 상품 Silver 테이블'
TBLPROPERTIES ('quality' = 'silver')
AS
SELECT
  TRIM(product_id) AS product_id,
  TRIM(product_name) AS product_name,
  TRIM(category) AS category,
  TRY_CAST(list_price AS INT) AS list_price
FROM bronze_products;

-- COMMAND ----------

CREATE OR REFRESH MATERIALIZED VIEW silver_orders_clean (
  CONSTRAINT valid_order_id EXPECT (order_id IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT valid_order_ts EXPECT (order_ts IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT positive_quantity EXPECT (quantity > 0) ON VIOLATION DROP ROW,
  CONSTRAINT positive_unit_price EXPECT (unit_price > 0) ON VIOLATION DROP ROW,
  CONSTRAINT valid_discount EXPECT (discount_pct BETWEEN 0 AND 100) ON VIOLATION DROP ROW,
  CONSTRAINT valid_status EXPECT (status IN ('COMPLETED', 'CANCELLED')) ON VIOLATION DROP ROW
)
COMMENT '배치 간 중복 제거, 타입 변환, NULL과 상태값을 표준화한 주문 Silver 테이블'
TBLPROPERTIES ('quality' = 'silver')
AS
WITH typed AS (
  SELECT
    TRIM(order_id) AS order_id,
    TRY_CAST(order_ts AS TIMESTAMP) AS order_ts,
    TRIM(store_id) AS store_id,
    TRIM(product_id) AS product_id,
    TRY_CAST(quantity AS INT) AS quantity,
    TRY_CAST(unit_price AS INT) AS unit_price,
    COALESCE(TRY_CAST(discount_pct AS DOUBLE), 0D) AS discount_pct,
    UPPER(TRIM(status)) AS status,
    _source_file,
    _ingested_at
  FROM bronze_orders
),
deduplicated AS (
  SELECT *
  FROM typed
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY order_id
    ORDER BY _source_file, _ingested_at
  ) = 1
)
SELECT * FROM deduplicated;

-- COMMAND ----------

CREATE OR REFRESH MATERIALIZED VIEW gold_sales
CLUSTER BY AUTO
COMMENT '완료 주문을 매장·상품과 결합하고 분석 파생값을 계산한 Gold 매출 테이블'
TBLPROPERTIES ('quality' = 'gold')
AS
SELECT
  o.order_id,
  o.order_ts,
  CAST(o.order_ts AS DATE) AS order_date,
  HOUR(o.order_ts) AS order_hour,
  CASE DAYOFWEEK(o.order_ts)
    WHEN 1 THEN '일'
    WHEN 2 THEN '월'
    WHEN 3 THEN '화'
    WHEN 4 THEN '수'
    WHEN 5 THEN '목'
    WHEN 6 THEN '금'
    WHEN 7 THEN '토'
  END AS day_name,
  CASE WHEN DAYOFWEEK(o.order_ts) IN (1, 7) THEN '주말' ELSE '평일' END AS day_type,
  CASE
    WHEN HOUR(o.order_ts) BETWEEN 6 AND 10 THEN '모닝'
    WHEN HOUR(o.order_ts) BETWEEN 11 AND 13 THEN '점심'
    WHEN HOUR(o.order_ts) BETWEEN 14 AND 17 THEN '오후'
    WHEN HOUR(o.order_ts) BETWEEN 18 AND 21 THEN '저녁'
    ELSE '야간'
  END AS daypart,
  o.store_id,
  s.store_name,
  s.region,
  o.product_id,
  p.product_name,
  p.category,
  o.quantity,
  o.unit_price,
  o.discount_pct,
  o.quantity * o.unit_price AS gross_sales,
  o.quantity * o.unit_price * o.discount_pct / 100D AS discount_amount,
  o.quantity * o.unit_price * (1D - o.discount_pct / 100D) AS net_sales
FROM silver_orders_clean o
INNER JOIN silver_stores s USING (store_id)
INNER JOIN silver_products p USING (product_id)
WHERE o.status = 'COMPLETED';
