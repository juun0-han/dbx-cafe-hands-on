-- Lakeflow Job의 SQL file task에서 실행하는 파이프라인 검증 쿼리

SELECT
  object_name,
  actual,
  expected,
  CASE WHEN actual = expected THEN 'PASS' ELSE 'FAIL' END AS result
FROM (
  SELECT 'bronze_orders' AS object_name, COUNT(*) AS actual, 300 AS expected
  FROM cafe_training.cafe_hands_on.bronze_orders
  UNION ALL
  SELECT 'silver_orders_clean', COUNT(*), 296
  FROM cafe_training.cafe_hands_on.silver_orders_clean
  UNION ALL
  SELECT 'gold_sales', COUNT(*), 266
  FROM cafe_training.cafe_hands_on.gold_sales
);
