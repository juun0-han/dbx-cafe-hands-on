# GitHub 반영 및 참가자 배포

저장소의 최신 문서를 GitHub `main` 브랜치에 반영하고, 참가자가 최신 커밋을 Git folder로 받는 절차입니다.

## 저장소

```text
Repository: https://github.com/juun0-han/dbx-cafe-hands-on.git
Branch: main
```

## 로컬 PowerShell에서 push

저장소 루트에서 실행합니다.

```powershell
cd "C:\Users\USER\Work\00_Test\outputs\019fe8ff-f2be-7d12-b114-a931dfde7a25\databricks_cafe_hands_on"
git status
git diff --check
git add HANDS_ON_SESSION_DESIGN.md README.md docs notebooks/06_mlflow_monitoring.py resources/app_resource_binding.example.yml
git status
git commit -m "Finalize hands-on integration guide"
git pull --rebase origin main
git push origin main
git status
```

마지막 `git status`에 다음이 표시되면 push가 완료된 상태입니다.

```text
Your branch is up to date with 'origin/main'.
nothing to commit, working tree clean
```

## Databricks Git folder 최신화

Databricks Workspace에서 Git folder를 엽니다.

```text
Git folder 메뉴 > Pull
```

또는 UI에 따라 다음 이름을 선택합니다.

```text
Git folder 메뉴 > Update
```

Branch는 다음과 같아야 합니다.

```text
main
```

## 참가자에게 전달할 내용

```text
GitHub URL: https://github.com/juun0-han/dbx-cafe-hands-on.git
Branch: main
첫 문서: docs/01_hands_on_runbook.md
Volume 업로드 파일: runbook의 2-3절 목록
참고 파일: runbook의 2-4절 및 2-5절 목록
```

참가자는 각자 개인 Workspace에서 같은 public repository를 Git folder로 Clone합니다. 별도 repository나 사용자별 접미사는 사용하지 않습니다.

## 최종 배포 전 확인

```text
README.md 링크 정상
docs/01_hands_on_runbook.md 최신
HANDS_ON_SESSION_DESIGN.md 최신
노트북과 resources 파일 포함
sample_data CSV 포함
Excel 참고 파일 포함
GitHub main 최신 커밋 확인
```
