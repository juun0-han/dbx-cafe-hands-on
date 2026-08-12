# 00. 시작하기

개인 Databricks Workspace에서 실습 환경을 준비하는 안내서입니다.

## 1. 권한 확인

- Unity Catalog 사용
- `cafe_training` Catalog에 대한 `USE CATALOG`
- Schema 생성 권한
- Volume 생성·업로드 권한
- SQL Warehouse 사용 권한
- Serverless Lakeflow Pipeline 사용 권한

Catalog 생성 권한이 없다면 Catalog 관리자에게 다음 SQL 실행을 요청합니다.

```sql
CREATE CATALOG IF NOT EXISTS cafe_training;
```

Catalog는 Unity Catalog 메타스토어 범위의 객체입니다. 여러 Workspace가 같은 메타스토어를 공유한다면 `cafe_training`이 서로 보일 수 있으므로 Workspace-Catalog binding 또는 별도 Catalog를 사용합니다.

## 2. Schema와 Volume 생성

Git folder에서 다음 노트북을 엽니다.

[`notebooks/00_setup.sql`](../notebooks/00_setup.sql)

노트북은 다음 객체를 생성합니다.

```text
cafe_training.cafe_landing
cafe_training.cafe_hands_on
cafe_training.cafe_landing.raw
```

## 3. CSV 업로드

다음 Volume 경로에 원천 CSV를 업로드합니다.

```text
/Volumes/cafe_training/cafe_landing/raw
```

파일 구조:

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

## 4. 완료 확인

- `cafe_training.cafe_landing` Schema 확인
- `cafe_training.cafe_hands_on` Schema 확인
- `raw` Volume 확인
- 매장·상품 CSV 확인
- 주문 배치 3개 확인
- `glossary.csv` 확인

완료 후 다음 단계로 이동합니다.
