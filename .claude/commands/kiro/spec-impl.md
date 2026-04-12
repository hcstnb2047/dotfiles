---
description: Execute spec tasks using TDD methodology with Generator-Evaluator loop
allowed-tools: Bash, Read, Write, Edit, MultiEdit, Grep, Glob, LS, WebFetch, WebSearch, mcp__playwright__browser_navigate, mcp__playwright__browser_snapshot, mcp__playwright__browser_click, mcp__playwright__browser_type, mcp__playwright__browser_take_screenshot, mcp__playwright__browser_evaluate
argument-hint: <feature-name> [task-numbers]
---

# Implementation Task Executor (with G-E Loop)

<background_information>
- **Mission**: Execute implementation tasks using Test-Driven Development with an automated Generator-Evaluator feedback loop
- **Success Criteria**:
  - Tests written before implementation code
  - All tests pass (unit + E2E smoke check) with no regressions
  - Tasks marked as completed in tasks.md
  - Implementation aligns with design and requirements
- **G-E Loop**: Initial implementation + up to 2 retry loops (3 attempts total). Each retry receives structured error context from the evaluator — not prose.
- **Playwright scope**: Smoke/exploration only, not full regression. High token cost (~4× CLI); use only for UI/API tasks where visual confirmation adds value.
</background_information>

<instructions>
## Core Task
Execute implementation tasks for feature **$1** using Test-Driven Development with a Generator-Evaluator loop.

## Step 1: Load Context

Read all necessary context:
- `.kiro/specs/$1/spec.json`, `requirements.md`, `design.md`, `tasks.md`
- **Entire `.kiro/steering/` directory**

Detect test framework: check `package.json`, `pyproject.toml`, `go.mod`, etc. Note the test command.

Detect Playwright E2E setup:
- Check for `playwright.config.*` in project root
- Extract base URL from `.kiro/steering/tech.md` field `dev_server_url`, or `spec.json` field `base_url`, or fall back to `http://localhost:3000`

Validate approvals: verify tasks are approved in spec.json (stop if not).

## Step 2: Select Tasks

- If `$2` provided: execute specified task numbers (e.g., "1.1" or "1,2,3")
- Otherwise: execute all pending tasks (`- [ ]` in tasks.md)
- Read `parallel_tasks` flag from spec.json (default: false if absent)

## Step 2.5: Parallel Dispatch (skip if parallel_tasks is false or $2 is a single task)

If `spec.json.parallel_tasks` is `true` AND the selected task list contains tasks marked with `(P)`:

1. **Split tasks**:
   - Parallel group: selected tasks with `(P)` marker
   - Sequential queue: selected tasks without `(P)` marker

2. **Launch parallel subagents**: For each task in the parallel group, spawn an Agent subagent concurrently with:
   - `isolation: "worktree"` to get an isolated git worktree (prevents file conflicts between parallel tasks)
   - Full spec context: contents of spec.json, requirements.md, design.md, tasks.md, and all `.kiro/steering/` files
   - Assigned task: the single task ID and its description from tasks.md
   - Instructions: Execute exactly one G-E Loop cycle (RED → GREEN → REFACTOR) for the assigned task following the Step 3 logic below; return a structured result: `{ "task_id": "...", "status": "pass"|"blocked", "worktree_branch": "<branch name>", "changed_files": ["<path>", ...], "error_context": {...}|null, "attempts": N }`
   - Do NOT mark tasks.md inside subagents (parent handles all writes)

3a. **Merge worktrees**: After all parallel agents complete, for each passed task:
   - `git merge --no-ff <worktree_branch>` to integrate changes
   - If merge conflict occurs: record as `blocked` with `"root_cause_hint": "merge conflict with <other_task_id>"`

3. **Collect results**: Wait for all parallel agents to complete; aggregate pass/fail + error_context

4. **Update tasks.md**: For each passed task mark `[x]`; for blocked tasks record error_context

5. **Run sequential queue**: Execute remaining non-(P) tasks one by one using Step 3 loop below

6. **Skip Step 3** entirely if all selected tasks were handled in parallel (no sequential queue remains)

## Step 3: Execute with TDD + G-E Loop

For each selected task, run the following cycle. **Maximum 3 attempts** (1 initial + 2 retries).

```
attempt = 0
error_context = null   ← structured JSON, null on first attempt

repeat:
  attempt++

  ── GENERATE ──────────────────────────────────────────────
  If attempt == 1:
    1. RED    — Write failing test for this task
    2. GREEN  — Implement minimal code to pass the test
    3. REFACTOR — Clean up; remove duplication; ensure all tests still pass
  Else (retry):
    Fix only what error_context reports. Do NOT rewrite unrelated code.
    Skip REFACTOR on retry to avoid noise.

  ── EVALUATE ──────────────────────────────────────────────
  Run mechanically verifiable checks only:

  CHECK 1 — Unit/integration tests (always)
    Run: <detected test command>
    Result: PASS | FAIL + captured stdout/stderr

  CHECK 2 — E2E smoke check (only if playwright.config.* exists AND task touches UI/API)
    - browser_navigate to base_url + relevant path
    - browser_snapshot to capture DOM state
    - browser_evaluate for key assertions
    - browser_take_screenshot for visual record
    Result: PASS | FAIL + snapshot diff / error message

  CHECK 3 — Requirements traceability (only on final PASS, not on retries)
    Grep for key identifiers from requirements.md related to this task.
    Result: COVERED | MISSING items

  ── STRUCTURED ERROR CONTEXT (on FAIL) ────────────────────
  Build error_context as structured JSON for next attempt.
  Use `spec.json.feedback_format` (default: "json") — always use JSON format:
  {
    "verdict": "fail",
    "attempt": <n>,
    "failed_check": "unit" | "e2e",
    "failed_criteria": ["<criterion that was violated>", ...],
    "failing_tests": ["<test name>: <assertion>", ...],
    "error_output": "<truncated stderr, max 500 chars>",
    "screenshot_path": "<path or null>",
    "root_cause_hint": "<one sentence diagnosis>",
    "suggested_fix": "<specific change needed to pass — file:line if known>"
  }

  ── DECISION ──────────────────────────────────────────────
  if CHECK 1 PASS and (CHECK 2 PASS or not applicable):
    → Run CHECK 3 (traceability)
    → MARK COMPLETE: update tasks.md [ ] → [x]
    → break
  elif attempt < 3:
    → pass error_context to next attempt
  else:
    → BLOCKED: record error_context, continue to next task
```

## Step 4: Output

Provide summary in the language specified in spec.json.

**Summary section** (≤200 words):
- Tasks completed / blocked / skipped
- For each task that needed retries: what failed and how it was fixed
- E2E results if Playwright ran (screenshot paths)

**Blocked tasks section** (appended if any, no word limit):
- Task ID, final error_context JSON, suggested next action

## Critical Constraints
- **TDD Mandatory**: Tests MUST be written before implementation code
- **Task Scope**: Implement only what the specific task requires
- **No Regressions**: Run full test suite after each task; stop if existing tests break
- **Design Alignment**: Follow design.md; flag deviations, do not silently diverge
- **REFACTOR only on GREEN**: Skip refactor on retries to keep diffs minimal
- **Traceability only on PASS**: Do not run grep-based checks inside the retry loop
</instructions>

## Tool Guidance
- **Bash**: test runs, lint, build commands
- **Playwright MCP**: smoke/visual check only — `browser_navigate`, `browser_snapshot`, `browser_evaluate`, `browser_take_screenshot`, `browser_click`, `browser_type`
- **WebSearch/WebFetch**: library docs when needed

## Safety & Fallback

**Tasks not approved / spec files missing**:
- Stop. Suggest: "Complete previous phases: `/kiro:spec-requirements`, `/kiro:spec-design`, `/kiro:spec-tasks`"

**BLOCKED after 3 attempts**:
- Do not halt the run. Record structured error_context and proceed to next task.
- Final summary lists all blocked tasks.

**Playwright unavailable or no config**:
- Skip E2E silently. Unit tests alone are sufficient for GO.

**No test framework detected**:
- Warn once at start. Skip automated test runs. Note "manual verification required" per task.

**dev_server_url not found in tech.md or spec.json**:
- Default to `http://localhost:3000`. Log the assumption in output.

### Task Execution Examples
```
/kiro:spec-impl feature-name          # all pending tasks
/kiro:spec-impl feature-name 1.1      # single task
/kiro:spec-impl feature-name 1,2,3    # multiple tasks
```
