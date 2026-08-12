# GitHub 저장소 연결

## GitHub 저장소 만들기

GitHub에서 저장소를 생성합니다. 합성 데이터 저장소는 Public으로 설정할 수 있습니다.

## 로컬 폴더 업로드

PowerShell에서 저장소 폴더로 이동한 뒤 실행합니다.

```powershell
cd "C:\path\to\databricks_cafe_hands_on"
git init
git add .
git commit -m "Cafe hands-on materials"
git branch -M main
git remote add origin https://github.com/<github-id>/databricks-cafe-hands-on.git
git push -u origin main
```

## 고정 버전 만들기

동일한 파일 구성을 유지하려면 태그를 만듭니다.

```powershell
git tag hands-on-v1
git push origin hands-on-v1
```

## Databricks에서 받기

개인 Workspace에서 다음 메뉴를 선택합니다.

```text
Workspace > Git folders > Clone repo
```

저장소 URL을 입력하고 `main` 브랜치를 선택한 뒤 [`00_start_here.md`](00_start_here.md)의 Catalog, Schema, Volume 준비부터 진행합니다.

비공개 저장소는 GitHub 읽기 권한과 Databricks Git 인증이 필요합니다.
