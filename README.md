# Databricks Cafe End-to-End Hands-on

개인 Databricks Workspace에서 Git folder로 clone하여 실행하는 카페 데이터 실습입니다.
코드를 새로 작성하기보다 제공된 notebook과 가이드의 순서대로 실행합니다.

## 실습 순서

1. [`docs/00_start_here.md`](docs/00_start_here.md)에서 Catalog, Schema, Volume을 준비합니다.
2. [`notebooks/00_setup.sql`](notebooks/00_setup.sql)로 환경을 확인하고 CSV를 업로드합니다.
3. [`notebooks/01_cafe_medallion_pipeline.sql`](notebooks/01_cafe_medallion_pipeline.sql)로 Bronze–Silver–Gold Pipeline을 만듭니다.
4. [`notebooks/02_metric_view_baseline.sql`](notebooks/02_metric_view_baseline.sql)과 `03_metric_view_optimized.sql`을 비교합니다.
5. `resources/genie_instructions.md`, `genie_questions.md`를 사용해 Genie Agent를 구성합니다.
6. `notebooks/05_create_ai_search.py`로 용어집 AI Search를 구성합니다.
7. `resources/supervisor_prompt.md`와 `resources/app.yaml.example`을 사용해 Supervisor Agent와 Databricks App을 구성합니다.
8. `notebooks/06_mlflow_monitoring.py`로 Trace와 평가 결과를 확인합니다.

전체 설계와 시간표는 [`HANDS_ON_SESSION_DESIGN.md`](HANDS_ON_SESSION_DESIGN.md)를 참고합니다.
GitHub 최초 업로드 절차는 [`docs/00_github_publish.md`](docs/00_github_publish.md)를 참고합니다.

## 기본 Unity Catalog 이름

개인 Workspace 기준 기본값은 다음과 같습니다.

```text
Catalog: cafe_training
Landing Schema: cafe_landing
Analytics Schema: cafe_hands_on
Volume: cafe_landing.raw
```

Workspace에 이미 제공된 개인 Catalog가 있다면 `databricks.yml`의 `catalog` 변수와 notebook의 Catalog 값을 그 이름으로 바꿉니다.

## Git folder로 받기

Databricks Workspace에서 `Workspace > Git folders > Clone repo`를 선택하고 이 저장소 URL을 입력합니다. 강사가 지정한 release tag 또는 `hands-on-v1` 브랜치를 선택합니다.

정식 배포에서는 참가자가 GitHub의 `main` 브랜치를 직접 수정하지 않도록 `CAN_RUN` 권한 또는 읽기 전용 release tag를 사용합니다.

## 데이터 위치

원천 CSV는 다음 Volume 경로에 업로드합니다.

```text
/Volumes/cafe_training/cafe_landing/raw/stores.csv
/Volumes/cafe_training/cafe_landing/raw/products.csv
/Volumes/cafe_training/cafe_landing/raw/orders/*.csv
/Volumes/cafe_training/cafe_landing/raw/support/glossary.csv
```

## Bundle 배포

저장소 루트의 `databricks.yml`을 열어 `warehouse_id` 값을 준비한 뒤, Workspace Bundle editor 또는 Databricks CLI에서 `dev` target을 검증·배포합니다.
