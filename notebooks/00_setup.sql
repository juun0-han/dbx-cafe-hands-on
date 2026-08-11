-- Databricks notebook source
-- MAGIC %md
-- MAGIC # 00. 카페 핸즈온 환경 준비
-- MAGIC
-- MAGIC 개인 Workspace에서 실행하는 시작 노트북입니다.
-- MAGIC 기본 Catalog는 `cafe_training`입니다. Catalog 생성 권한이 없으면 강사가 먼저 Catalog만 생성합니다.

-- COMMAND ----------

CREATE CATALOG IF NOT EXISTS cafe_training;

CREATE SCHEMA IF NOT EXISTS cafe_training.cafe_landing
COMMENT '카페 핸즈온 원천 파일용 스키마';

CREATE SCHEMA IF NOT EXISTS cafe_training.cafe_hands_on
COMMENT '카페 핸즈온 Bronze, Silver, Gold, Metric View용 스키마';

CREATE VOLUME IF NOT EXISTS cafe_training.cafe_landing.raw
COMMENT '카페 핸즈온 CSV 업로드 볼륨';

-- COMMAND ----------

-- 다음 로컬 폴더의 내용을 Catalog Explorer에서 Volume으로 업로드합니다.
-- sample_data/raw/stores.csv          -> /Volumes/cafe_training/cafe_landing/raw/stores.csv
-- sample_data/raw/products.csv        -> /Volumes/cafe_training/cafe_landing/raw/products.csv
-- sample_data/raw/orders/*.csv        -> /Volumes/cafe_training/cafe_landing/raw/orders/*.csv
-- sample_data/support/glossary.csv    -> /Volumes/cafe_training/cafe_landing/raw/support/glossary.csv

LIST '/Volumes/cafe_training/cafe_landing/raw';

-- COMMAND ----------

SELECT
  '환경 준비 완료' AS status,
  '/Volumes/cafe_training/cafe_landing/raw' AS upload_path,
  'cafe_training.cafe_hands_on' AS target_schema;
