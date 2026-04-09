# Claude Agent 구성 계획

## Phase 1: 기본 설정
- [x] CLAUDE.md 기본 골격 작성
  - [x] 언어 규칙 (영어 문서 / 한국어 대화)
  - [x] 200% 확신 원칙
  - [x] 협의 후 실행 원칙
  - [x] No Emoji 규칙
  - [x] Workflow 규칙 (sync-fork 필수, reference/ 수정 금지)
  - [x] Atlassian 설정 (site, default project)

## Phase 1.5: 권한 설정
- [x] `.claude/settings.json` 생성 — 모든 도구 허용 설정

## Phase 2: Skills 구성
- [x] `.claude/skills/` 디렉토리 구조 생성
- [x] GitHub 스킬
  - [x] `get-repo` — upstream 원본을 reference/에 클론 (읽기 전용)
  - [x] `create-branch` — work/에 포크+클론+동기화+브랜치 생성 통합
  - [x] `sync-fork` — reference/ git pull + work/ 포크 동기화
  - [x] `commit-push` — diff 분석 + 커밋 메시지 자동 생성 + 푸시
  - [x] `pr` — PR 템플릿 자동 작성 + upstream master로 PR 생성
- [x] `setup-check` — 개발환경 검증 (기존 스킬 적용)
- [x] `agents/swagger` — Swagger 정리 에이전트 (기존 적용)
- [x] Jira 스킬 정의 (`.claude/skills/jira/`)
    - [x] `get-issue` — 티켓 조회
    - [x] `my-issues` — 내 담당 티켓 목록
    - [x] `analyze-issue` — 티켓 분석 + 댓글 작성
    - [x] `create-issue` — 티켓 생성
    - [x] `update-issue` — 티켓 수정/상태 전환
    - [x] `comment` — 댓글 추가
    - [x] `search-issues` — JQL 검색
- [ ] Confluence 스킬 정의 (`.claude/skills/confluence/`) — 추후

## Phase 2.5: FSC (Full Software Cycle) 스킬
- [ ] `/fsc` 스킬 정의 (`.claude/skills/fsc/SKILL.md`)
  - Input: Jira 티켓 ID
  - Step 1: 티켓 분석 → 요구사항/설계문서를 티켓 댓글로 작성
  - Step 2: 다중 Agent 검증 (요구사항/설계 리뷰) → 통과할 때까지 반복
  - Step 3: Git 브랜치 생성 + 로컬 클론
  - Step 4: 개발 수행
  - Step 5: 다중 Agent 코드 리뷰/검증 → 통과할 때까지 반복
  - Step 6: 커밋 + 푸시 + PR 생성

## Phase 3: MCP 서버 연동
- [x] Google Calendar 연동 (claude.ai 내장)
- [x] Gmail 연동 (claude.ai 내장)
- [x] Computer Use 연동 (claude.ai 내장)
- [x] Atlassian (Jira/Confluence) 연동 — `.mcp.json` 설정
- [x] GitHub — gh CLI 사용 (MCP 미사용)

## Phase 4: Rules (지식베이스) 구성
- [x] `.claude/rules/` 디렉토리 구조 생성
- [x] Knowledge Auto-Collection 규칙 추가 — 서비스 정보 자동 수집 (`.claude/rules/cloudops/{service}.md`)
- [ ] `architecture.md` — 시스템 구조, 컴포넌트 관계 (서비스 형상 확정 후)
- [ ] `code-style.md` — 코딩 컨벤션 (서비스 형상 확정 후)
- [ ] `api-design.md` — API 패턴 (서비스 형상 확정 후)
- [ ] `security.md` — 보안 가이드라인 (서비스 형상 확정 후)
- [ ] `cloudops/backend.md` — 백엔드 규칙, 경로 스코핑 (서비스 형상 확정 후)
- [ ] `cloudops/frontend.md` — 프론트엔드 규칙, 경로 스코핑 (서비스 형상 확정 후)

## Phase 5: Hooks 설정
- [x] PreToolUse — reference/ 수정 강제 차단 (Edit/Write)
- [ ] Notification — Claude 대기 시 macOS 알림 (추후)
- [ ] SessionStart — 세션 시작 시 컨텍스트 자동 주입 (추후)

## Phase 6: 권한/환경 설정
- [ ] 허용 명령어 설정
- [ ] 환경변수 설정
