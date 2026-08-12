# Databricks Cafe Hands-on 실행 가이드

GitHub 저장소를 Databricks 개인 Workspace에 연결한 뒤 카페 데이터의 메달리온 Pipeline, Lakeflow Job, Metric View, Genie Agent를 구성하는 실행 가이드입니다.

## 0. 고정 이름

| 대상 | 이름 또는 값 |
|---|---|
| GitHub repository | `https://github.com/juun0-han/dbx-cafe-hands-on.git` |
| Git branch | `main` |
| Git folder | `dbx-cafe-hands-on` |
| Catalog | `cafe_training` |
| Landing Schema | `cafe_landing` |
| Analytics Schema | `cafe_hands_on` |
| Volume | `cafe_training.cafe_landing.raw` |
| Pipeline | `cafe_medallion_pipeline` |
| Job | `cafe_medallion_job` |
| Pipeline task | `run_medallion_pipeline` |
| Validation task | `validate_pipeline` |
| Metric View | `cafe_training.cafe_hands_on.cafe_sales_metrics` |
| Genie Agent | `Cafe Sales Genie Agent` |

## 1. 사전 조건

- Unity Catalog 사용
- `cafe_training`에 대한 `USE CATALOG`
- Schema 생성 권한
- Volume 생성·업로드 권한
- SQL Warehouse 사용 권한
- Serverless Lakeflow Pipeline 사용 권한
- Gold 테이블 `SELECT`
- `cafe_hands_on` Schema `CREATE TABLE`
- Genie Agent 생성·편집 권한

Catalog 생성 권한이 없다면 Catalog 관리자에게 다음 SQL 실행을 요청합니다.

```sql
CREATE CATALOG IF NOT EXISTS cafe_training;
```

## 2. GitHub 저장소를 Git folder로 받기

Databricks Workspace에서 다음 메뉴를 선택합니다.

```text
Workspace > Git folders > Clone repo
```

입력값:

```text
Git repository URL: https://github.com/juun0-han/dbx-cafe-hands-on.git
Provider: GitHub
Git folder name: dbx-cafe-hands-on
Branch: main
```

`Create Git folder`를 클릭합니다. 생성된 폴더는 다음 형식입니다.

```text
/Workspace/Users/<사용자 이메일>/dbx-cafe-hands-on
```

다음 구조가 보여야 합니다.

```text
README.md
databricks.yml
docs/
notebooks/
resources/
sample_data/
```

### 2-1. 먼저 열어볼 문서

Git folder를 만든 직후 다음 가이드부터 엽니다.

```text
docs/01_hands_on_runbook.md
```

함께 확인할 문서:

```text
README.md
docs/00_start_here.md
HANDS_ON_SESSION_DESIGN.md
```

`docs/01_hands_on_runbook.md`에는 현재 실습에 사용하는 이름, 경로, 화면 입력값, 검증값이 모두 정리되어 있습니다.
Git folder clone이나 GitHub ZIP 다운로드에 이 파일이 포함되어 있는지 확인하고, 실습 중에는 이 문서를 함께 열어 둡니다.

### 2-2. 로컬 PC로 파일 내려받기

Volume 업로드 화면은 로컬 파일을 선택하므로, 다음 방법 중 하나로 저장소 파일을 로컬 PC에 준비합니다.

방법 A: GitHub 저장소 화면에서 `Code > Download ZIP`을 선택한 뒤 압축을 해제합니다.

방법 B: GitHub 저장소를 로컬 PC에 clone합니다.

```powershell
git clone https://github.com/juun0-han/dbx-cafe-hands-on.git
```

Git folder 안의 문서·노트북은 Workspace에서 직접 열어도 됩니다. 로컬 다운로드는 아래 Volume 업로드 파일과 Excel·CSV 참고 파일을 확인할 때 사용합니다.

### 2-3. Volume에 업로드할 파일

다음 6개 파일만 Volume에 업로드합니다.

```text
sample_data/raw/stores.csv
sample_data/raw/products.csv
sample_data/raw/orders/orders_batch_001.csv
sample_data/raw/orders/orders_batch_002.csv
sample_data/raw/orders/orders_batch_003.csv
sample_data/support/glossary.csv
```

README, 노트북, YAML, Markdown, Excel, 평가용 CSV는 Volume에 업로드하지 않습니다.

### 2-4. 실습 중 열어볼 참고 파일

| 시점 | 열어볼 파일 | 용도 |
|---|---|---|
| 시작 | `docs/01_hands_on_runbook.md` | 전체 실행 절차 |
| 시작 | `docs/00_start_here.md` | Catalog·Schema·Volume 준비 |
| 시작 | `README.md` | 저장소 구조와 실행 순서 |
| Pipeline | `notebooks/01_cafe_medallion_pipeline.sql` | Bronze·Silver·Gold 소스 확인 |
| Pipeline 검증 | `notebooks/04_pipeline_validate.sql` | Job 검증 SQL 확인 |
| 기대값 확인 | `sample_data/support/expected_results.csv` | 행 수와 지표 기대값 확인 |
| 데이터 설명 | `sample_data/support/data_dictionary.csv` | 컬럼과 업무 의미 확인 |
| Metric View | `notebooks/02_metric_view_baseline.sql` | 기준선 정의 확인 |
| Metric View | `notebooks/03_metric_view_optimized.sql` | 설명·동의어·포맷 확인 |
| Genie 지침 | `resources/genie_instructions.md` | 일반 지침 입력 |
| Genie 질문 | `resources/genie_questions.md` | 기본·분석·다의어 질문 |
| Genie 예제 | `sample_data/support/genie_example_queries.csv` | Example Query 입력 SQL |
| Genie 평가 | `sample_data/support/genie_benchmarks.csv` | Benchmark 질문과 정답 |
| AI Search | `sample_data/support/glossary.csv` | 용어집 원본 |
| Agent 평가 | `sample_data/support/agent_evaluation.csv` | Agent 평가 질문 |
| Apps | `resources/supervisor_prompt.md` | Supervisor 지침 |
| Apps | `resources/app.yaml.example` | App 설정 예시 |
| Apps | `resources/app_resource_binding.example.yml` | App 리소스 연결 예시 |
| MLflow | `notebooks/06_mlflow_monitoring.py` | Trace·평가 확인 |

### 2-5. Excel 파일 사용

다음 Excel 파일은 참고용이며 Volume에 업로드하지 않습니다.

```text
cafe_hands_on_assets.xlsx
cafe_sample_data_review.xlsx
```

Excel에서는 샘플 데이터, 데이터 사전, 기대 결과, Genie 질문·Benchmark 구성을 한눈에 확인할 수 있습니다. 실행 중 값이 예상과 다를 때 `expected_results.csv`와 함께 확인합니다.

## 3. Catalog, Schema, Volume 준비

Git folder에서 다음 파일을 열고 SQL Warehouse를 연결한 뒤 `Run all`을 클릭합니다.

```text
notebooks/00_setup.sql
```

생성 객체:

```text
cafe_training.cafe_landing
cafe_training.cafe_hands_on
cafe_training.cafe_landing.raw
```

Catalog Explorer에서 다음 구조를 확인합니다.

```text
cafe_training
├── cafe_landing
│   └── Volumes
│       └── raw
└── cafe_hands_on
```

## 4. CSV를 Volume에 업로드

Catalog Explorer에서 다음 위치를 엽니다.

```text
Catalog > cafe_training > cafe_landing > Volumes > raw
```

`raw` Volume 안에 `orders`, `support` 디렉터리를 만듭니다.

`Add data > Upload files to a volume`로 다음 파일을 업로드합니다.

```text
Destination: /Volumes/cafe_training/cafe_landing/raw
Files: sample_data/raw/stores.csv, sample_data/raw/products.csv
```

```text
Destination: /Volumes/cafe_training/cafe_landing/raw/orders
Files: sample_data/raw/orders/orders_batch_001.csv
       sample_data/raw/orders/orders_batch_002.csv
       sample_data/raw/orders/orders_batch_003.csv
```

```text
Destination: /Volumes/cafe_training/cafe_landing/raw/support
Files: sample_data/support/glossary.csv
```

최종 구조:

```text
raw/
├── stores.csv
├── products.csv
├── orders/
│   ├── orders_batch_001.csv
│   ├── orders_batch_002.csv
│   └── orders_batch_003.csv
└── support/
    └── glossary.csv
```

## 5. Lakeflow Pipeline 생성

다음 메뉴를 선택합니다.

```text
Workflows > Pipelines > Create pipeline
```

Pipeline 설정:

```text
Pipeline name: cafe_medallion_pipeline
Source file: notebooks/01_cafe_medallion_pipeline.sql
Catalog: cafe_training
Schema: cafe_hands_on
Serverless: On
Product edition: Advanced
Channel: Current
Pipeline mode: Triggered
```

Source가 폴더 단위로 표시되면 다음 폴더에서 `01_cafe_medallion_pipeline.sql`을 선택합니다.

```text
/Workspace/Users/<사용자 이메일>/dbx-cafe-hands-on/notebooks
```

`Create` 후 `Start` 또는 `Run pipeline`을 클릭합니다.

생성 데이터셋:

```text
bronze_stores, bronze_products, bronze_orders
silver_stores, silver_products, silver_orders_clean
gold_sales
```

모든 노드가 성공하면 Catalog Explorer에서 `cafe_training.cafe_hands_on`의 위 테이블을 확인합니다.

## 6. Lakeflow Job 생성

다음 메뉴를 선택합니다.

```text
Jobs & Pipelines > Jobs > Create job
```

Job 이름:

```text
cafe_medallion_job
```

### Task 1: Pipeline 실행

```text
Task name: run_medallion_pipeline
Task type: Pipeline
Pipeline: cafe_medallion_pipeline
Full refresh: Off
```

### Task 2: Pipeline 검증

`Add task` 후 다음을 입력합니다.

```text
Task name: validate_pipeline
Task type: SQL
SQL task type: File
SQL Warehouse: 앞 단계에서 사용한 SQL Warehouse
```

SQL 파일:

```text
notebooks/04_pipeline_validate.sql
```

Workspace Source인 경우:

```text
/Workspace/Users/<사용자 이메일>/dbx-cafe-hands-on/notebooks/04_pipeline_validate.sql
```

Git provider Source인 경우:

```text
Repository: https://github.com/juun0-han/dbx-cafe-hands-on.git
Branch: main
Path: notebooks/04_pipeline_validate.sql
```

`validate_pipeline`의 Dependency:

```text
Depends on: run_medallion_pipeline
```

Job DAG:

```text
run_medallion_pipeline
          ↓
   validate_pipeline
```

`Save` 후 `Run now`를 클릭합니다. 예상 결과:

```text
bronze_orders          actual 300   expected 300   PASS
silver_orders_clean    actual 296   expected 296   PASS
gold_sales             actual 266   expected 266   PASS
```

## 7. Metric View 기준선 생성

다음 파일을 SQL Warehouse에서 `Run all`합니다.

```text
notebooks/02_metric_view_baseline.sql
```

생성 객체:

```text
cafe_training.cafe_hands_on.cafe_sales_metrics
```

마지막 쿼리의 예상값:

```text
net_sales: 1,734,580
order_count: 266
avg_order_value: 약 6,520.98
```

## 8. Metric View 최적화 정의 적용

다음 파일을 같은 SQL Warehouse에서 `Run all`합니다.

```text
notebooks/03_metric_view_optimized.sql
```

적용되는 메타데이터:

```text
표시명: 순매출, 주문수, 판매수량, 객단가
동의어: 매출, 실매출, 결제매출, 판매액 등
포맷: 매출·객단가 KRW, 주문수·판매수량 정수
Materialization: daily_store_category, 하루 1회
```

최적화 후에도 `net_sales=1,734,580`, `order_count=266`, `avg_order_value=약 6,520.98`인지 확인합니다.

## 9. Genie Agent 생성

다음 메뉴를 선택합니다.

```text
Genie > New
```

Agent 이름:

```text
Cafe Sales Genie Agent
```

데이터 자산에는 다음 Metric View 하나만 추가합니다.

```text
cafe_training.cafe_hands_on.cafe_sales_metrics
```

`Configure > Context > Instructions`의 입력값:

```text
# 카페 매출 Genie Agent 지침

## 목적과 범위

- 카페 매출 데이터를 사용해 사용자의 질문에 근거 있는 분석 결과를 제공한다.
- 분석 대상은 연결된 Metric View에 정의된 필드, 측정값, 설명, 동의어로 제한한다.
- 데이터 자산에 없는 컬럼, 지표, 고객 정보는 임의로 만들지 않는다.
- 응답은 한국어 존댓말로 작성한다.

## 질문 해석 규칙

- 사용자의 표현을 Metric View의 표시명, 설명, 동의어와 연결해 해석한다.
- 비슷한 개념이라도 의미가 다른 필드와 측정값은 구분한다. 예: 금액과 수량, 주문 건수와 판매 수량, 총액과 순액.
- 사용자가 지표를 명확히 지정하지 않으면 Metric View에 정의된 기본 의미를 사용하고, 응답에 적용한 지표를 표시한다.
- 기간, 비교 기준, 집계 수준 또는 정렬 기준이 결과에 큰 영향을 주는데 질문에 포함되지 않았다면 짧게 되묻는다.
- 하나의 표현이 여러 필드나 지표로 해석될 수 있으면 가능한 선택지를 제시하고 사용자의 확인을 받는다.

## 데이터 및 계산 규칙

- Metric View에 정의된 측정값과 차원을 우선 사용한다.
- 이미 정의된 측정값이 있는 경우 원시 컬럼을 임의로 다시 계산하지 않는다.
- 데이터에 없는 정보나 근거 없는 원인을 추정하지 않는다.
- 요청한 데이터가 없으면 제공할 수 없다고 명확히 설명하고, 대신 사용할 수 있는 관련 지표나 차원을 제안한다.
- 필터와 기간을 적용한 경우 실제 적용 조건을 응답에 명시한다.

## 응답 형식

- 수치에는 적절한 단위와 측정값 이름을 표시한다.
- 비교나 추이 분석은 가능한 경우 표로 제시하고, 정렬 기준과 기간을 함께 표시한다.
- 결과 뒤에 핵심 해석을 간결하게 덧붙인다.
- 답변은 데이터로 확인할 수 있는 사실과 해석을 구분한다.
```

## 10. Genie Example Query 등록

`Configure > Context > Add`를 클릭하면 다음 메뉴가 표시됩니다.

```text
Example Query
Filter
Measure
Field
Join
```

현재는 `Example Query`만 선택합니다.

| 메뉴 | 현재 단계 | 용도 |
|---|---|---|
| Example Query | 사용 | 질문과 정답 SQL 등록 |
| Filter | 사용하지 않음 | 재사용 필터 조건 |
| Measure | 사용하지 않음 | 별도 지표 계산식 |
| Field | 사용하지 않음 | 컬럼 설명·동의어 |
| Join | 사용하지 않음 | 여러 데이터 자산 관계 |

다음 파일의 6개 항목을 Example Query로 등록합니다.

```text
sample_data/support/genie_example_queries.csv
```

각 항목의 `Question`과 `SQL`을 하나의 Example Query로 입력합니다.

### E001

Question:

```text
전체 기간 순매출은 얼마야?
```

SQL:

```sql
SELECT MEASURE(net_sales) AS net_sales
FROM cafe_training.cafe_hands_on.cafe_sales_metrics;
```

### E002

Question:

```text
매장별 순매출을 비교해줘
```

SQL:

```sql
SELECT store_name,
       MEASURE(net_sales) AS net_sales
FROM cafe_training.cafe_hands_on.cafe_sales_metrics
GROUP BY store_name
ORDER BY net_sales DESC;
```

### E003

Question:

```text
판매수량 기준 TOP 3 메뉴는?
```

SQL:

```sql
SELECT product_name,
       MEASURE(item_quantity) AS item_quantity
FROM cafe_training.cafe_hands_on.cafe_sales_metrics
GROUP BY product_name
ORDER BY item_quantity DESC
LIMIT 3;
```

### E004

Question:

```text
일자별 순매출 추이를 보여줘
```

SQL:

```sql
SELECT order_date,
       MEASURE(net_sales) AS net_sales
FROM cafe_training.cafe_hands_on.cafe_sales_metrics
GROUP BY order_date
ORDER BY order_date;
```

### E005

Question:

```text
시간대별 순매출과 주문수를 비교해줘
```

SQL:

```sql
SELECT daypart,
       MEASURE(net_sales) AS net_sales,
       MEASURE(order_count) AS order_count
FROM cafe_training.cafe_hands_on.cafe_sales_metrics
GROUP BY daypart
ORDER BY net_sales DESC;
```

### E006

Question:

```text
매장별 객단가가 높은 순서로 보여줘
```

SQL:

```sql
SELECT store_name,
       MEASURE(avg_order_value) AS avg_order_value
FROM cafe_training.cafe_hands_on.cafe_sales_metrics
GROUP BY store_name
ORDER BY avg_order_value DESC;
```

채팅 화면에서 다음 질문을 테스트합니다.

```text
전체 기간 순매출은 얼마야?
```

예상 결과:

```text
순매출 약 1,734,580원
```

다음 질문은 바로 SQL을 실행하지 않고 되물어야 합니다.

```text
인기메뉴가 뭐야?
라떼 매출 알려줘.
손님이 가장 많은 매장은 어디야?
```

예상 동작:

```text
인기메뉴 → 매출 기준인지 판매수량 기준인지 질문
라떼 → 카페라떼인지 바닐라라떼인지 질문
손님 → 고객 데이터가 없음을 설명하고 주문수 또는 판매수량을 질문
```

## 11. 최종 확인표

- Git folder가 `main` 브랜치로 연결됨
- Catalog·Schema·Volume 생성 완료
- 원천 CSV와 `glossary.csv` 업로드 완료
- `cafe_medallion_pipeline` 성공
- `cafe_medallion_job`의 두 Task 성공
- `bronze_orders=300`, `silver_orders_clean=296`, `gold_sales=266`
- Metric View 기준선 및 최적화 정의 성공
- `Cafe Sales Genie Agent` 생성 완료
- Metric View 하나만 연결됨
- Example Query 6개 등록 완료
- 순매출 질문 정상 응답
- 다의어 질문에서 되묻는 응답 확인

