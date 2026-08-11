# 00. 시작하기

이 문서는 강사가 GitHub 저장소를 공유한 뒤 참가자가 처음 실행하는 안내서입니다.

## 1. 권한 확인

다음 권한이 필요합니다.

- Unity Catalog 사용
- `cafe_training` Catalog에 대한 `USE CATALOG`
- Schema 생성 권한
- Volume 생성·업로드 권한
- SQL Warehouse 사용 권한
- Serverless Lakeflow Pipeline 사용 권한

Catalog 생성 권한이 없다면 강사가 먼저 다음 SQL을 한 번 실행합니다.

```sql
CREATE CATALOG IF NOT EXISTS cafe_training;
```

참고: Catalog는 Workspace가 아니라 Unity Catalog 메타스토어 범위의 객체입니다. 여러 개인 Workspace가 같은 메타스토어를 공유한다면 `cafe_training`이 서로 보일 수 있으므로, 강사는 Workspace-Catalog binding 또는 참가자별 Catalog를 사용해 데이터가 섞이지 않는지 먼저 확인합니다.

## 2. Schema와 Volume 생성

참가자는 개인 Workspace에서 다음 노트북을 Git folder에서 열어 실행합니다.

[`notebooks/00_setup.sql`](../notebooks/00_setup.sql)

노트북은 다음 객체를 생성합니다.

```text
cafe_training.cafe_landing
cafe_training.cafe_hands_on
cafe_training.cafe_landing.raw
```

## 3. CSV 업로드

저장소의 `sample_data/raw` 및 `sample_data/support/glossary.csv`를 다음 Volume 위치에 업로드합니다.

```text
/Volumes/cafe_training/cafe_landing/raw
```

주문 CSV 세 개는 `orders` 폴더에, `glossary.csv`는 `support` 폴더에 업로드합니다.

## 4. 완료 기준

- `cafe_training.cafe_landing` Schema 확인
- `cafe_training.cafe_hands_on` Schema 확인
- `raw` Volume 확인
- 매장·상품 CSV 확인
- 주문 배치 3개 확인
- `glossary.csv` 확인

완료 후 강사의 안내에 따라 다음 단계로 이동합니다.
