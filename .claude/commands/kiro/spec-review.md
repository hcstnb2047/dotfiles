---
description: Run parallel AI pre-review on a specification phase before human approval
allowed-tools: Read, Glob, Agent, Write, WebSearch, WebFetch
argument-hint: <feature-name> [--phase=requirements|design|tasks]
---

# AI Pre-Review Gate (spec-review)

<background_information>
- **Mission**: Run parallel AI quality review on the current spec phase, surfacing issues before human review. Acts as an "AI quality gate" that reduces human review burden by pre-filtering and focusing attention on what actually needs a human decision.
- **Success Criteria**:
  - Validates artifacts against user personas from steering context
  - Applies challenge-style critical analysis (non-interactive batch mode)
  - Dynamically selects domain-appropriate reviewer lenses based on feature content
  - Produces a numbered Human Review Agenda that focuses human attention
</background_information>

<instructions>
## Core Task
Run parallel AI review on feature **$1** spec artifacts for the specified phase, then synthesize findings into a Human Review Agenda.

## Execution Steps

### Step 1: Resolve Phase and Load Context

**Determine phase from $2**:
- `--phase=requirements` → review `requirements.md`
- `--phase=design` → review `requirements.md` + `design.md`
- `--phase=tasks` → review `requirements.md` + `design.md` + `tasks.md`
- (no flag) → infer from `spec.json.phase`:
  - `requirements-generated` → requirements
  - `design-generated` → design
  - `tasks-generated` → tasks
  - ambiguous → stop and ask user for explicit `--phase`

**Load all context**:
- `.kiro/specs/$1/spec.json` (language, feature description, current phase)
- Phase artifacts as determined above
- All `.kiro/steering/` files in the current project directory
- Search for `personas.md` in any `.kiro/steering/` path (project-level overrides harness-level)

### Step 2: Classify Feature and Select Reviewer Lenses

Read the spec artifacts to classify the feature, then select **the 2 most relevant reviewer lenses**:

| Lens | Apply when |
|------|-----------|
| Security | Auth, API keys, data access controls, user input processing |
| Accessibility | UI components, mobile-first, cognitive load, error messaging |
| Performance | Caching strategies, data volume, latency-sensitive paths |
| Data Privacy | PII handling, local/remote storage, retention policies |
| Maintainability | Coupling, testability, abstraction complexity, tech debt risk |
| Scalability | Concurrent usage, data growth over time, stateful components |
| UX Flow | User journeys, error recovery, onboarding, edge case handling |
| Integration Risk | External APIs, library versions, compatibility, breaking changes |

Record your lens selection rationale briefly for the review report.

### Step 3: Run Parallel AI Reviews

Launch **3 agents in parallel** using the Agent tool with subagent_type="general-purpose":

**Agent A — Challenge Review**

Prompt:
```
You are performing a non-interactive challenge review of the following specification artifact.

Feature: [FEATURE_NAME]
Phase: [PHASE]

--- ARTIFACT START ---
[ARTIFACT_CONTENT]
--- ARTIFACT END ---

Apply this 6-perspective analysis. For each perspective with significant findings, output a numbered finding (C-1, C-2...). Skip perspectives with no meaningful issues. Aim for 3-5 total findings maximum — prioritize impact over completeness.

Perspectives:
1. 前提の検証: What assumptions are taken for granted that should be verified or challenged?
2. 盲点と甘い解釈: What is the spec ignoring, downplaying, or optimistically underestimating?
3. 機会損失: What important requirements, options, or user needs are missing entirely?
4. 隠れた矛盾: Are there internal contradictions within the artifact, or between phases?
5. 強みの見落とし: What existing patterns, capabilities, or context could be better leveraged?
6. 問いの再構成: Is this solving the right problem? Is the feature framing correct?

Output format per finding:
C-N | [Perspective] | [Priority: High/Medium/Low] | [1-2 sentence description]
```

**Agent B — User Persona Gate**

Prompt:
```
You are performing a persona-based validation of the following specification artifact.

Feature: [FEATURE_NAME]
Phase: [PHASE]

--- PERSONAS ---
[PERSONAS_CONTENT]
--- PERSONAS END ---

--- ARTIFACT START ---
[ARTIFACT_CONTENT]
--- ARTIFACT END ---

For each persona, evaluate:
1. Does this feature meet their core goal?
2. Are there friction points, barriers, or unmet needs?
3. Are there assumptions in the spec that contradict their constraints?

Output numbered findings (P-1, P-2...) only for issues found. Skip personas with no concerns.

Output format per finding:
P-N | [Persona name] | [Priority: High/Medium/Low] | [1-2 sentence description]

If no persona issues are found, output: "P: No persona-related issues identified."
```

**Agent C — Specialist Review**

Prompt:
```
You are performing a specialist review of the following specification artifact through two specific lenses.

Feature: [FEATURE_NAME]
Phase: [PHASE]
Reviewer lenses: [LENS_1] and [LENS_2]

--- ARTIFACT START ---
[ARTIFACT_CONTENT]
--- ARTIFACT END ---

For [LENS_1]:
Review through the [LENS_1] lens. Focus on concrete, actionable concerns only.

For [LENS_2]:
Review through the [LENS_2] lens. Focus on concrete, actionable concerns only.

Output numbered findings (S-1, S-2...). Aim for 2-4 total findings.

Output format per finding:
S-N | [Lens] | [Priority: High/Medium/Low] | [1-2 sentence description]
```

### Step 4: Synthesize Findings

Collect all findings (C-*, P-*, S-*). Then:

1. **Merge and deduplicate**: If multiple agents raised the same issue, merge them and note all sources
2. **Assign final priority**: High if any agent rated it High; escalate if multiple agents flagged independently
3. **Generate recommendation**:
   - 承認可 (Approve) — no High priority findings
   - 要修正 (Needs revision) — 1-3 High priority findings
   - 要再設計 (Needs redesign) — multiple High findings or fundamental framing issue

### Step 4.5: Best Practice Research (for High/Medium findings with known patterns)

For each High and Medium finding where the issue involves a **design decision that has established best practices** (e.g., auth patterns, data modeling, API design, error handling strategies, caching approaches):

1. Identify whether this is a "general best practice exists" question or a "depends on user intent" question
   - General best practice → proceed with WebSearch
   - User-intent dependent → skip; flag for human judgment instead

2. Run WebSearch: `"[finding topic] best practice [tech stack if known]"` or equivalent
   - Max 1-2 searches per finding; do not over-research
   - If no clear consensus found in 2 searches, skip and note "明確な標準解なし"

3. Record findings as `BP-N` references to attach to the review report

**Do NOT research**:
- Business logic decisions (only user can decide)
- Findings flagged Low priority
- Spec framing / problem definition issues

### Step 5: Write Human Review Agenda

Write the full report to `.kiro/specs/$1/review-[phase].md` (e.g. `review-requirements.md`).
Include a `## ベストプラクティス参考` section if any BP-N references were found.

Display a concise summary to the console.

## Output Format

### File: `.kiro/specs/$1/review-[phase].md`

```markdown
---
date: [ISO_TIMESTAMP]
feature: [FEATURE_NAME]
phase: [PHASE]
reviewer_lenses: [challenge, persona-gate, LENS_1, LENS_2]
recommendation: [承認可|要修正|要再設計]
---

# AI Pre-Review: [FEATURE_NAME] — [Phase]

## サマリー
- 総発見事項: N件（High: N / Medium: N / Low: N）
- レビュアー: Challenge + Persona Gate + [Lens1] + [Lens2]
- 推奨: [承認可 / 要修正 / 要再設計]

## Human Review Agenda

### 🔴 High Priority（必ず確認）

1. **[Finding title]** `[C-1 / P-2 / S-1]`
   > [1-2 sentence description of the issue]
   > **人間が決めるべきこと**: [specific decision or judgment needed]

### 🟡 Medium Priority（確認推奨）

N. **[Finding title]** `[source]`
   > [description]

### 🟢 Low Priority（任意確認）

N. **[Finding title]** `[source]`
   > [description]

## 推奨アクション
- [ ] [Specific action 1]
- [ ] [Specific action 2]

## ベストプラクティス参考
<!-- Step 4.5 でリサーチした内容のみ記載。リサーチ不要だった場合はこのセクションを省略 -->
- **BP-1** `[Finding ID]` — [best practice summary] ([source URL])

## 次のステップ
- High Priorityがある場合: 修正後に `/kiro:spec-review $1 --phase=[phase]` を再実行
- 全件確認済みの場合: 次フェーズへ進む
```

### Console Summary (under 150 words)

Display:
1. Recommendation (承認可/要修正/要再設計) prominently
2. Finding counts by priority
3. Top 1-2 High priority items if any
4. Path to review file
5. Next command

## Important Constraints
- This is a PRE-human-review step, NOT a replacement for human review
- Output findings as questions/concerns for human judgment, not decisions
- Do NOT modify spec artifacts (requirements.md, design.md, tasks.md) — write only to review-[phase].md
- Use language specified in `spec.json` for all output
- The challenge review runs in non-interactive batch mode: do not ask the user questions
</instructions>

## Tool Guidance
- **Read first**: Load all context before launching agents
- **Agent tool**: Launch all 3 review agents in a single parallel call
- **Write**: Output only to `review-[phase].md`, never to spec artifacts

## Safety & Fallback

**Personas Not Found**:
- Warning: "personas.md not found in steering directories. Skipping persona gate."
- Proceed: Run Challenge + Specialist (2 agents instead of 3)
- Suggestion: "Create `.kiro/steering/personas.md` to enable persona-based validation"

**Phase Inference Failure**:
- Stop: "Cannot infer review phase from spec.json. Please specify: `/kiro:spec-review $1 --phase=requirements|design|tasks`"

**Agent Failure**:
- If a parallel agent fails, complete remaining agents and note the failure in the report
- Never retry; proceed with available results and report what's missing

**All-Clear Result**:
- If all agents return no significant findings: Report "No significant issues found. Spec quality looks good."
- Still write review-[phase].md with the all-clear report
- Recommendation: 承認可

**Next Phase Guidance**:

After review is complete, guide user based on recommendation:
- 承認可 → proceed to next kiro:spec-* phase
- 要修正 → address High priority items, then re-run spec-review or proceed to next phase
- 要再設計 → revisit current phase generation before proceeding
