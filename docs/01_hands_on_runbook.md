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

## 11. Genie Benchmark 등록 및 실행

Benchmark는 Genie Agent의 답변 정확도를 반복 측정하기 위한 테스트 질문 모음입니다. Chat 모드는 등록된 SQL Answer의 결과셋과 Genie 결과를 비교하고, Agent 모드는 Evaluation note를 기준으로 평가합니다. 실행할 때 `Chat` 또는 `Agent` 모드를 선택합니다.

### 11-1. Benchmark 입력 파일

```text
sample_data/support/genie_benchmarks.csv
```

파일의 열은 다음과 같습니다.

```text
benchmark_id, mode, category, question, sql_answer, evaluation_note, expected_behavior
```

### 11-2. Benchmark 추가

다음 메뉴를 선택합니다.

```text
Cafe Sales Genie Agent > Benchmarks > Add benchmark
```

Chat 모드 B001~B008은 다음 값을 입력합니다.

```text
Question: CSV의 question 열
SQL Answer: CSV의 sql_answer 열
Evaluation note: 비워 둠
```

Chat Benchmark 질문:

```text
B001  전체 기간 순매출은 얼마야?
B002  매장별 매출을 높은 순서로 알려줘
B003  가장 많이 팔린 메뉴 3개 알려줘
B004  카테고리별 순매출을 비교해줘
B005  날짜별 매출 추이를 보여줘
B006  시간대별 매출과 주문수를 비교해줘
B007  강남점 객단가는 얼마야?
B008  주말과 평일의 순매출을 비교해줘
```

Agent 모드 B009~B012는 다음 값을 입력합니다.

```text
Question: CSV의 question 열
SQL Answer: 비워 둠
Evaluation note: CSV의 evaluation_note 열
```

Agent Benchmark 입력값:

```text
B009
Question: 인기메뉴가 뭐야?
Evaluation note: 매출 기준인지 판매수량 기준인지 질문해야 한다.

B010
Question: 손님이 가장 많은 매장은 어디야?
Evaluation note: 고객 데이터가 없음을 알리고 주문수와 판매수량 중 의미를 확인해야 한다.

B011
Question: 라떼 매출 알려줘.
Evaluation note: 카페라떼와 바닐라라떼 중 어느 상품인지 질문해야 한다.

B012
Question: 최근 매출 추이를 보여줘
Evaluation note: 데이터 최대일 2026-07-14 기준 최근 7일을 사용하고 실제 기간을 응답에 밝혀야 한다.
```

### 11-3. Benchmark 실행

Chat Benchmark 실행:

```text
Benchmarks > B001~B008 선택 > Run selected > Mode: Chat
```

Agent Benchmark 실행:

```text
Benchmarks > B009~B012 선택 > Run selected > Mode: Agent
```

실행이 끝나면 `Evaluations`에서 다음 값을 기록합니다.

```text
Evaluation name:
Execution status:
Accuracy:
Good 문항:
Bad 또는 Manual Review 문항:
```

### 11-4. Monitor 확인

다음 메뉴를 선택합니다.

```text
Cafe Sales Genie Agent > Monitor
```

다음 항목을 확인합니다.

```text
질문과 응답
생성 SQL
평점
상태
Fix it
Request review
Weekly digest
```

사용자 피드백만으로 Agent의 Instruction이 자동 변경되지는 않습니다. 문제가 반복되는 질문을 확인한 뒤 다음 품질 최적화 절차로 수정합니다.

## 12. Genie 품질 최적화 일반 가이드

### 12-1. 기능별 역할

| 구성 요소 | 넣을 내용 |
|---|---|
| Metric View | 필드·측정값의 의미, 표시명, 설명, 동의어, 포맷, 공통 업무 규칙 |
| Example Query | 자주 사용하는 질문과 검증된 SQL 패턴 |
| Instruction | 여러 질문에 공통으로 적용되는 해석·응답 원칙 |
| Benchmark | 정확도와 회귀 테스트를 위한 질문·SQL Answer·Evaluation note |
| Monitor | 실제 질문, 생성 SQL, 피드백, 반복 오류 |

### 12-2. 권장 개선 순서

1. Metric View 하나만 연결한 기준선을 실행합니다.
2. 필드와 측정값에 표시명·설명·동의어·포맷을 정의합니다.
3. 대표 질문의 검증된 SQL을 Example Query로 추가합니다.
4. 동일한 Benchmark를 다시 실행해 개선 전후 Accuracy를 비교합니다.
5. 실패한 질문의 생성 SQL과 SQL Answer를 비교합니다.
6. 원인에 맞는 구성 요소 하나만 수정합니다.
7. 같은 문항을 재실행하고 다른 문항의 회귀 여부도 확인합니다.

### 12-3. 실패 원인별 수정 위치

| 관찰된 문제 | 우선 수정할 위치 |
|---|---|
| 용어가 잘못된 필드나 측정값으로 연결됨 | Metric View의 표시명·설명·동의어 |
| 반복되는 질문 유형의 SQL 패턴이 불안정함 | Example Query |
| 여러 질문에 공통으로 적용할 해석 규칙이 부족함 | Instruction |
| 정답 SQL 또는 평가 기준이 잘못됨 | Benchmark의 SQL Answer·Evaluation note |
| 실제 사용 질문에서 같은 오류가 반복됨 | Monitor에서 원인 확인 후 위 항목 중 하나 수정 |

### 12-4. 생성 SQL 검토와 Add as instruction

실패한 응답에서 다음 메뉴를 선택합니다.

```text
... > Show code
```

다음 항목을 비교합니다.

```text
생성 SQL
SQL Answer
실행 결과
```

생성 SQL을 수정한 경우 실행 결과가 올바른지 확인한 뒤 다음 메뉴를 선택합니다.

```text
... > Add as instruction
```

이 기능은 질문과 검증된 SQL을 재사용 가능한 예제로 저장하는 용도로 사용합니다. 생성 SQL을 검토하지 않은 상태로 저장하지 않습니다.

### 12-5. Instruction 작성 원칙

- 전체 Instruction을 질문별 규칙 모음으로 만들지 않습니다.
- 하나의 규칙은 여러 질문에 적용될 때만 추가합니다.
- 데이터에 없는 정보나 원인을 추정하도록 지시하지 않습니다.
- 이미 Metric View에 정의된 측정값을 원시 컬럼으로 다시 계산하도록 지시하지 않습니다.
- 기간·비교 기준·집계 수준처럼 결과에 큰 영향을 주는 조건이 모호하면 짧게 확인하도록 합니다.

일반적인 Instruction 예시는 다음과 같습니다.

```text
질문에 기간, 비교 기준, 집계 수준 또는 정렬 기준이 명시되지 않아 결과가 달라질 수 있으면 실행 전에 필요한 기준을 짧게 확인한다.
```

### 12-6. 재평가 기준

```text
개선 전 Accuracy:
개선 후 Accuracy:
수정한 Benchmark ID:
수정한 구성 요소:
회귀가 발생한 문항:
```

실패한 문항이 없다면 불필요한 Instruction을 추가하지 않고 현재 Accuracy를 기준선으로 기록합니다.

## 13. AI Search 용어집 구성

AI Search는 약어·동의어·다의어·업무 규칙을 검색하는 용어집 계층입니다. 검색 결과가 하나의 표준 의미로 확정되면 Supervisor가 해당 의미를 Genie Agent에 전달합니다.

### 13-1. 고정 이름

```text
Source table: cafe_training.cafe_hands_on.cafe_glossary
AI Search endpoint: cafe-ai-search-endpoint
AI Search index: cafe_training.cafe_hands_on.cafe_glossary_index
Primary key: term_id
Embedding source: search_text
Sync mode: TRIGGERED
Query type: HYBRID
Top results: 3
```

### 13-2. 원본 파일 확인

다음 파일이 Volume에 있어야 합니다.

```text
/Volumes/cafe_training/cafe_landing/raw/support/glossary.csv
```

원본 용어집은 19개 행이며 `term_id`, `term`, `aliases`, `definition`, `metric_or_field`, `resolution_rule`, `example_question`, `updated_at`, `search_text` 컬럼을 포함합니다.

### 13-3. 노트북 실행

Git folder에서 다음 노트북을 엽니다.

```text
notebooks/05_create_ai_search.py
```

사용 가능한 Python Compute를 연결하고 첫 번째 셀을 실행합니다.

```python
%pip install -q --upgrade databricks-ai-search
dbutils.library.restartPython()
```

Python이 재시작되면 노트북을 다시 열고 위에서부터 순서대로 실행합니다.

위젯 기본값:

```text
Catalog: cafe_training
Schema: cafe_hands_on
AI Search endpoint: cafe-ai-search-endpoint
Embedding model: databricks-qwen3-embedding-0-6b
```

### 13-4. Delta 테이블 확인

용어집 CSV를 읽는 셀과 테이블 생성 셀을 실행합니다.

예상 테이블:

```text
cafe_training.cafe_hands_on.cafe_glossary
```

Catalog Explorer에서 다음을 확인합니다.

```text
행 수: 19
Primary key: term_id
검색 텍스트: search_text
Change Data Feed: 활성화
```

### 13-5. Endpoint와 Index 확인

Endpoint 생성 셀을 실행한 뒤 다음 화면에서 상태를 확인합니다.

```text
AI Search > Endpoints > cafe-ai-search-endpoint
```

상태가 다음과 같아야 합니다.

```text
ONLINE
```

Endpoint가 `ONLINE`인 뒤 Index 생성 셀을 실행합니다.

```text
Index: cafe_training.cafe_hands_on.cafe_glossary_index
Source: cafe_training.cafe_hands_on.cafe_glossary
Primary key: term_id
Embedding source: search_text
Sync mode: TRIGGERED
```

### 13-6. Triggered Sync와 검색 실행

Index를 만든 뒤 다음 셀을 실행합니다.

```python
index.sync()
```

Catalog Explorer에서 Index 상태가 `ONLINE`이고 Indexed rows가 19인지 확인합니다.

노트북 마지막 검색 셀은 Hybrid 검색을 실행합니다.

```python
results = index.similarity_search(
    query_text="아메 매출과 피크타임을 알려줘",
    columns=["term_id", "term", "definition", "resolution_rule"],
    num_results=3,
    query_type="HYBRID",
)
display(results)
```

다음 검색어도 실행합니다.

```text
라떼 매출
손님수
최근 매출
주말 매출
```

예상 검색 규칙:

```text
아메 → 아메리카노
피크타임 → 시간대별 순매출 비교
라떼 → 카페라떼 또는 바닐라라떼 중 선택 필요
손님수 → 고객 데이터 없음, 주문수 또는 판매수량 제안
최근 → 데이터 최대일 기준 직전 7일
주말 → 토요일과 일요일
```

### 13-7. AI Search 완료 기준

```text
cafe_glossary 테이블 생성
행 수 19개
cafe-ai-search-endpoint 상태 ONLINE
cafe_glossary_index 상태 ONLINE
Triggered Sync 완료
Hybrid 검색 결과 Top 3 확인
아메·피크타임·라떼·손님수 검색 규칙 확인
```

## 14. Databricks Apps 구성

AI Playground에서 검증한 Supervisor Agent를 Databricks Apps로 배포합니다. App은 Genie Agent와 AI Search Index를 리소스로 연결하고, MLflow Experiment에 Trace를 기록합니다.

### 14-1. Playground에서 App으로 내보내기

AI Playground에서 Supervisor 구성 화면을 엽니다.

```text
Get code > Export to Databricks Apps
```

입력값:

```text
App name: agent-cafe-supervisor
App description: 카페 매출 Genie와 용어집 AI Search를 연결한 Supervisor Agent
MLflow experiment: cafe-supervisor-agent
```

`Export` 후 생성된 App을 엽니다.

```text
Apps > agent-cafe-supervisor
```

### 14-2. App Resource 연결

App 설정에서 다음 메뉴를 엽니다.

```text
Settings > Resources
```

다음 리소스를 추가하거나 Export 결과를 확인합니다.

| Resource type | 대상 | Resource key | 권한 |
|---|---|---|---|
| Genie Agent | `Cafe Sales Genie Agent` | `cafe_genie` | Can run |
| AI Search index | `cafe_training.cafe_hands_on.cafe_glossary_index` | `cafe_glossary_index` | Can select |
| MLflow experiment | `cafe-supervisor-agent` | `cafe_experiment` | Can edit 이상 |

AI Search Index의 UI 리소스 유형은 Workspace 버전에 따라 `AI Search index` 또는 `Vector search index`로 표시될 수 있습니다.

앱 리소스는 App 서비스 주체에 최소 권한으로 부여합니다. AI Search Index는 `Can select`, Genie Agent는 `Can run` 권한을 사용합니다. ([Databricks Apps 리소스 문서](https://docs.databricks.com/aws/en/dev-tools/databricks-apps/resources))

### 14-3. 환경 변수 확인

`resources/app.yaml.example`의 리소스 키와 App Resources의 키가 일치해야 합니다.

```yaml
env:
  - name: GENIE_SPACE_ID
    valueFrom: cafe_genie
  - name: VECTOR_SEARCH_INDEX
    valueFrom: cafe_glossary_index
  - name: MLFLOW_EXPERIMENT_ID
    valueFrom: cafe_experiment
```

현재 Databricks UI의 `Genie Agent`가 내부 환경 변수에서 `GENIE_SPACE_ID`라는 이름을 사용하는 경우가 있으므로, 예제의 환경 변수 이름은 변경하지 않습니다.

### 14-4. App 실행과 확인

App 상태가 다음과 같아야 합니다.

```text
Status: Running
```

다음 질문을 각각 실행합니다.

```text
매장별 순매출을 비교해줘
아메 매출 알려줘
라떼 매출 알려줘
손님 수가 가장 많은 매장은?
```

예상 흐름:

```text
표준 질문: Supervisor → Genie Agent
별칭 질문: Supervisor → AI Search → Genie Agent
다의어 질문: Supervisor → AI Search → 사용자 명확화
미지원 개념: Supervisor → AI Search → 대체 지표 안내
```

App에서 각 질문의 응답과 도구 호출 순서를 확인합니다.

## 15. MLflow Trace·평가·모니터링

MLflow Trace는 Supervisor의 입력·출력·모델 호출·Genie 호출·AI Search 호출·실행 시간 등을 기록합니다. 개발 단계에서는 Trace를 조회하고 Scorer로 평가하며, 운영 단계에서는 같은 Scorer를 Production Monitoring에 재사용할 수 있습니다. ([MLflow 공식 문서](https://docs.databricks.com/aws/en/mlflow3/genai/eval-monitor))

### 15-1. Trace 생성

먼저 App에서 다음 평가 질문을 실행합니다.

```text
매장별 순매출을 비교해줘
아메 매출 알려줘
라떼 매출 알려줘
손님 수가 가장 많은 매장은?
```

전체 평가 질문은 다음 파일에서 확인합니다.

```text
sample_data/support/agent_evaluation.csv
```

### 15-2. MLflow 노트북 실행

Git folder에서 다음 노트북을 엽니다.

```text
notebooks/06_mlflow_monitoring.py
```

Python Compute를 연결하고 첫 번째 셀을 실행합니다.

```python
%pip install -q --upgrade "mlflow[databricks]>=3.4.0"
dbutils.library.restartPython()
```

Python 재시작 후 노트북을 다시 열고 다음 셀부터 실행합니다.

### 15-3. MLflow Experiment 지정

위젯에 App에서 연결한 MLflow Experiment 경로를 입력합니다.

```text
experiment_path: /Shared/cafe-supervisor-agent
```

App Export 화면에서 다른 경로를 사용했다면 해당 경로를 입력합니다. 노트북과 App이 같은 Experiment를 사용해야 App Trace가 조회됩니다.

예상 출력:

```text
MLflow experiment: /Shared/cafe-supervisor-agent
```

### 15-4. Trace 조회

Trace 조회 셀을 실행합니다.

```python
traces = mlflow.search_traces(max_results=30)
display(traces)
```

Trace에서 다음 항목을 확인합니다.

```text
입력 질문
최종 응답
Supervisor 모델 호출
Genie Agent Tool span
AI Search Tool span
Trace 상태
전체 latency
각 단계 latency
```

질문별 예상 Tool 경로:

```text
매장별 순매출: genie
아메 매출: ai_search → genie
라떼 매출: ai_search
손님 수: ai_search
```

### 15-5. 기본 Scorer 평가

평가 셀을 실행하면 다음 Scorer가 실행됩니다.

```python
from mlflow.genai.scorers import (
    RelevanceToQuery,
    Safety,
    ToolCallCorrectness,
)
```

평가 결과에서 다음 값을 확인합니다.

```text
RelevanceToQuery
Safety
ToolCallCorrectness
```

노트북은 `evaluation.metrics`와 `evaluation.result_df`를 출력합니다.

```python
print(evaluation.metrics)
display(evaluation.result_df)
```

`ToolCallCorrectness`는 Trace의 Tool span을 사용해 도구 선택과 인자를 평가합니다. ([MLflow ToolCallCorrectness 문서](https://mlflow.org/docs/latest/genai/eval-monitor/scorers/llm-judge/tool-call/correctness/))

### 15-6. MLflow UI 확인

Workspace 왼쪽 메뉴에서 다음을 선택합니다.

```text
AI/ML > Experiments
```

`/Shared/cafe-supervisor-agent` Experiment를 열고 다음 탭을 확인합니다.

```text
Traces
Evaluations
Runs
```

Trace 하나를 열어 입력, 출력, Tool span, latency를 확인합니다. Evaluation 결과에서는 Scorer별 결과와 실패한 질문을 확인합니다.

### 15-7. 운영 모니터링 선택 실습

Production Monitoring Preview가 Workspace에서 활성화된 경우에만 다음 셀을 실행합니다.

```python
from mlflow.genai.scorers import Safety, ScorerSamplingConfig

safety_monitor = Safety().register(name="cafe_safety")
safety_monitor = safety_monitor.start(
    sampling_config=ScorerSamplingConfig(sample_rate=0.5)
)
print(safety_monitor)
```

샘플링 비율은 다음과 같습니다.

```text
sample_rate: 0.5
```

### 15-8. 완료 기준

```text
App 질문 4개 이상 실행
MLflow Experiment에 Trace 생성
Genie·AI Search Tool span 확인
latency 확인
RelevanceToQuery·Safety·ToolCallCorrectness 실행
Evaluation 결과 확인
MLflow UI에서 Trace와 Evaluation 확인
Production Monitoring은 Preview일 때만 선택 실행
```

## 16. 최종 통합 검증

각 기능을 따로 확인한 뒤 하나의 사용자 질문이 `Supervisor → AI Search/Genie → App → MLflow` 흐름을 통과하는지 검증합니다.

### 16-1. 데이터와 의미 계층 확인

```text
bronze_orders = 300
silver_orders_clean = 296
gold_sales = 266
net_sales = 1,734,580
order_count = 266
avg_order_value ≈ 6,520.98
```

확인 대상:

```text
cafe_training.cafe_hands_on.gold_sales
cafe_training.cafe_hands_on.cafe_sales_metrics
```

### 16-2. Genie 상태 확인

```text
Genie Agent: Cafe Sales Genie Agent
연결 자산: cafe_training.cafe_hands_on.cafe_sales_metrics 하나
Example Query: 6개
Chat Benchmark: 8개
Agent Benchmark: 4개
Evaluations: 최소 1회
Monitor: 질문·응답·생성 SQL 확인
```

### 16-3. AI Search 상태 확인

```text
Source table: cafe_training.cafe_hands_on.cafe_glossary
행 수: 19
Endpoint: cafe-ai-search-endpoint / ONLINE
Index: cafe_training.cafe_hands_on.cafe_glossary_index / ONLINE
Sync: TRIGGERED 완료
Query type: HYBRID
```

### 16-4. App 통합 질문 실행

App에서 다음 4개 질문을 새 대화로 각각 실행합니다.

```text
Q1. 매장별 순매출을 비교해줘
Q2. 아메 매출 알려줘
Q3. 라떼 매출 알려줘
Q4. 손님 수가 가장 많은 매장은?
```

질문별 기대 결과:

| 질문 | 기대 Tool 경로 | 기대 결과 |
|---|---|---|
| Q1 | Genie | 매장별 순매출 표 |
| Q2 | AI Search → Genie | `아메`를 `아메리카노`로 해석한 매출 결과 |
| Q3 | AI Search | 카페라떼·바닐라라떼 중 선택 질문 |
| Q4 | AI Search | 고객 데이터 부재와 주문수·판매수량 대안 안내 |

예상 결과가 다르면 App의 응답, 도구 호출, AI Search 검색 결과, Genie 생성 SQL 순서로 확인합니다.

### 16-5. MLflow 통합 확인

MLflow Experiment에서 Q1~Q4 Trace를 확인합니다.

```text
Q1: Genie Tool span
Q2: AI Search Tool span → Genie Tool span
Q3: AI Search Tool span
Q4: AI Search Tool span
```

각 Trace에서 다음 값을 기록합니다.

```text
trace_id:
question:
tool_sequence:
status:
latency:
RelevanceToQuery:
Safety:
ToolCallCorrectness:
```

### 16-6. 최종 결과 기록

```text
Genie Chat Accuracy:
Genie Agent Accuracy:
Supervisor routing 결과:
MLflow Trace 개수:
RelevanceToQuery 결과:
Safety 결과:
ToolCallCorrectness 결과:
가장 먼저 개선할 항목:
```

### 16-7. 실습 완료 기준

```text
데이터 행 수와 Metric View 지표 확인
Genie Example Query·Benchmark·Monitor 확인
AI Search Endpoint·Index ONLINE 확인
App에서 Q1~Q4 실행
Q1~Q4의 기대 Tool 경로 확인
MLflow에서 Q1~Q4 Trace 확인
세 가지 Scorer 결과 확인
개선할 항목 한 가지 기록
```

## 17. GitHub 반영 및 참가자 배포

최종 검증이 끝난 문서를 GitHub `main` 브랜치에 반영합니다.

자세한 명령어:

```text
docs/00_github_publish.md
```

PowerShell 실행 위치:

```text
C:\Users\USER\Work\00_Test\outputs\019fe8ff-f2be-7d12-b114-a931dfde7a25\databricks_cafe_hands_on
```

최종 반영 명령:

```powershell
git status
git diff --check
git add HANDS_ON_SESSION_DESIGN.md README.md docs notebooks/06_mlflow_monitoring.py resources/app_resource_binding.example.yml
git commit -m "Finalize hands-on integration guide"
git pull --rebase origin main
git push origin main
git status
```

GitHub 반영 후 Databricks Git folder에서 다음을 선택합니다.

```text
Git folder 메뉴 > Pull 또는 Update
Branch: main
```

참가자는 각자 개인 Workspace에서 같은 public repository를 Clone합니다. 별도 repository나 사용자별 접미사는 사용하지 않습니다.

## 18. 최종 확인표

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
- Chat Benchmark 8개 등록 및 실행 완료
- Agent Benchmark 4개 등록 및 실행 완료
- Evaluations에서 Accuracy 확인
- Monitor에서 질문·응답·생성 SQL 확인
- `cafe_glossary` 테이블과 AI Search Index 생성 완료
- AI Search Endpoint와 Index가 `ONLINE`
- Triggered Sync와 Hybrid 검색 결과 확인
- `agent-cafe-supervisor` App 실행
- Genie·AI Search·MLflow Resource 연결
- MLflow Trace 생성 및 Tool span 확인
- RelevanceToQuery·Safety·ToolCallCorrectness 평가 완료
- 순매출 질문 정상 응답
- 다의어 질문에서 되묻는 응답 확인

