# Databricks Cafe End-to-End Hands-on

개인 Databricks Workspace에서 Git folder로 실행하는 카페 데이터 실습입니다.

## 실행 순서

1. [`docs/00_start_here.md`](docs/00_start_here.md)에서 Catalog, Schema, Volume을 준비합니다.
2. [`notebooks/00_setup.sql`](notebooks/00_setup.sql)로 환경을 확인합니다.
3. CSV를 Volume에 업로드합니다.
4. [`notebooks/01_cafe_medallion_pipeline.sql`](notebooks/01_cafe_medallion_pipeline.sql)로 Bronze–Silver–Gold Pipeline을 실행합니다.
5. [`notebooks/02_metric_view_baseline.sql`](notebooks/02_metric_view_baseline.sql)과 [`notebooks/03_metric_view_optimized.sql`](notebooks/03_metric_view_optimized.sql)로 Metric View를 구성합니다.
6. `resources/genie_instructions.md`와 `resources/genie_questions.md`를 사용해 Genie Agent를 구성합니다.
7. [`docs/01_hands_on_runbook.md`](docs/01_hands_on_runbook.md)의 Genie Example Query, Benchmark, Monitor, 품질 최적화 절차를 실행합니다.
8. [`notebooks/05_create_ai_search.py`](notebooks/05_create_ai_search.py)로 용어집 AI Search를 구성합니다.
9. `resources/supervisor_prompt.md`와 `resources/app.yaml.example`을 사용해 Supervisor Agent와 Databricks App을 구성합니다.
10. [`notebooks/06_mlflow_monitoring.py`](notebooks/06_mlflow_monitoring.py)로 Trace와 평가 결과를 확인합니다.
11. [`docs/01_hands_on_runbook.md`](docs/01_hands_on_runbook.md)의 최종 통합 검증에서 Q1~Q4 Tool routing과 MLflow Trace를 확인합니다.

전체 실습 설계는 [`HANDS_ON_SESSION_DESIGN.md`](HANDS_ON_SESSION_DESIGN.md)를 참고합니다.
GitHub 저장소 연결 절차는 [`docs/00_github_publish.md`](docs/00_github_publish.md)를 참고합니다.
처음부터 따라 하는 실행 절차는 [`docs/01_hands_on_runbook.md`](docs/01_hands_on_runbook.md)를 참고합니다.
Git folder를 받은 뒤에는 이 실행 가이드를 먼저 열고, Volume에 업로드할 CSV와 실습 중 확인할 Excel·CSV 목록을 가이드에서 확인합니다.

## Unity Catalog 이름

```text
Catalog: cafe_training
Landing Schema: cafe_landing
Analytics Schema: cafe_hands_on
Volume: cafe_landing.raw
```

## Git folder

Databricks Workspace에서 `Workspace > Git folders > Clone repo`를 선택하고 저장소 URL을 입력합니다. 실행 파일은 저장소의 `main` 브랜치에 있습니다.

## 데이터 위치

```text
/Volumes/cafe_training/cafe_landing/raw/stores.csv
/Volumes/cafe_training/cafe_landing/raw/products.csv
/Volumes/cafe_training/cafe_landing/raw/orders/*.csv
/Volumes/cafe_training/cafe_landing/raw/support/glossary.csv
```

## Bundle

저장소 루트의 `databricks.yml`에서 `warehouse_id` 값을 지정한 뒤 `dev` target을 검증·배포합니다.
