# GitHub에 실습 저장소 올리기

이 저장소는 합성 카페 데이터와 Databricks 실행 파일만 포함합니다. 토큰, 비밀번호, `.databricks/` 또는 생성 결과물은 `.gitignore`로 제외합니다.

## 1. GitHub에서 빈 저장소 만들기

GitHub에서 `New repository`를 선택하고 저장소 이름을 정합니다. 아래 항목은 체크하지 않습니다.

- Add a README file
- Add .gitignore
- Choose a license

예시 저장소 이름: `databricks-cafe-hands-on`

## 2. 로컬 폴더를 최초 업로드

PowerShell에서 이 폴더로 이동한 다음 실행합니다.

```powershell
cd "C:\path\to\databricks_cafe_hands_on"
git init
git add .
git commit -m "Initial cafe hands-on materials"
git branch -M main
git remote add origin https://github.com/<github-id>/databricks-cafe-hands-on.git
git push -u origin main
```

`<github-id>`와 저장소 이름은 실제 값으로 바꿉니다. 인증을 요청하면 GitHub 계정의 HTTPS 인증 방식 또는 GitHub CLI 로그인을 사용합니다. 토큰을 파일에 적거나 커밋하지 않습니다.

## 3. 강사용 고정 버전 만들기

세션에서 동일한 파일을 사용하려면 첫 업로드 후 태그를 만듭니다.

```powershell
git tag hands-on-v1
git push origin hands-on-v1
```

파일을 수정한 뒤에는 새 태그(`hands-on-v2`)를 만들어 참가자에게 공유할 수 있습니다.

## 4. 참가자가 Databricks에서 받기

개인 Workspace에서 `Workspace > Git folders > Clone repo`를 선택하고 저장소 URL을 입력합니다. 강사가 지정한 `hands-on-v1` 태그 또는 브랜치를 선택합니다. 이후 [`00_start_here.md`](00_start_here.md)의 Catalog, Schema, Volume 준비부터 진행합니다.

비공개 저장소라면 참가자 각자가 GitHub 저장소 읽기 권한과 Git 자격 증명을 가져야 합니다. 공개 저장소라면 별도 초대 없이 clone할 수 있습니다.
