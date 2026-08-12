# Databricks notebook source
# MAGIC %md
# MAGIC # 05. 카페 용어집 AI Search 구성
# MAGIC
# MAGIC 제공된 `glossary.csv`를 Delta 테이블로 만들고 Triggered Delta Sync Index를 생성합니다.
# MAGIC 참가자는 셀을 순서대로 실행하고 마지막 검색 결과만 확인합니다.

# COMMAND ----------

# MAGIC %pip install -q --upgrade databricks-ai-search
# MAGIC dbutils.library.restartPython()

# COMMAND ----------

dbutils.widgets.text("catalog", "cafe_training", "Catalog")
dbutils.widgets.text("schema", "cafe_hands_on", "Schema")
dbutils.widgets.text("endpoint_name", "cafe-ai-search-endpoint", "AI Search endpoint")
dbutils.widgets.text("embedding_model", "databricks-qwen3-embedding-0-6b", "Embedding model")

catalog = dbutils.widgets.get("catalog")
schema = dbutils.widgets.get("schema")
endpoint_name = dbutils.widgets.get("endpoint_name")
embedding_model = dbutils.widgets.get("embedding_model")

source_table = f"{catalog}.{schema}.cafe_glossary"
index_name = f"{catalog}.{schema}.cafe_glossary_index"
glossary_path = f"/Volumes/{catalog}/cafe_landing/raw/support/glossary.csv"

print({"source_table": source_table, "index_name": index_name, "glossary_path": glossary_path})

# COMMAND ----------

glossary_df = (
    spark.read.option("header", True)
    .option("encoding", "UTF-8")
    .csv(glossary_path)
)
glossary_df.createOrReplaceTempView("cafe_glossary_upload")

spark.sql(
    f"""
    CREATE OR REPLACE TABLE {source_table}
    TBLPROPERTIES (delta.enableChangeDataFeed = true)
    COMMENT '카페 약어·동의어·다의어와 지표 해석 규칙'
    AS SELECT * FROM cafe_glossary_upload
    """
)

display(spark.table(source_table))

# COMMAND ----------

from databricks.ai_search.client import AISearchClient

client = AISearchClient()

try:
    client.get_endpoint(name=endpoint_name)
    print(f"기존 endpoint 사용: {endpoint_name}")
except Exception:
    client.create_endpoint(name=endpoint_name, endpoint_type="STANDARD")
    print(f"endpoint 생성 요청: {endpoint_name}")

# Endpoint가 ONLINE이 될 때까지 UI에서 상태를 확인합니다.

# COMMAND ----------

try:
    index = client.get_index(index_name=index_name)
    print(f"기존 index 사용: {index_name}")
except Exception:
    index = client.create_delta_sync_index(
        endpoint_name=endpoint_name,
        source_table_name=source_table,
        index_name=index_name,
        pipeline_type="TRIGGERED",
        primary_key="term_id",
        embedding_source_column="search_text",
        embedding_model_endpoint_name=embedding_model,
        columns_to_sync=[
            "term",
            "aliases",
            "definition",
            "metric_or_field",
            "resolution_rule",
            "example_question",
            "search_text",
        ],
    )
    print(f"index 생성 요청: {index_name}")

# COMMAND ----------

index = client.get_index(index_name=index_name)
index.sync()
print("Triggered sync를 시작했습니다. Catalog Explorer에서 ONLINE 상태를 확인하세요.")

# COMMAND ----------

index = client.get_index(index_name=index_name)
results = index.similarity_search(
    query_text="아메 매출과 피크타임을 알려줘",
    columns=["term_id", "term", "definition", "resolution_rule"],
    num_results=3,
    query_type="HYBRID",
)
display(results)
