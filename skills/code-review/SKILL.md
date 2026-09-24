---
name: code-review
description: Review repository changes for concrete correctness, security, reliability, performance, and test gaps. Use for diffs, commits, branches, or integrated changes; do not use to implement fixes.
---

# Review code changes

Answer: **What could actually go wrong because of this change, and what meaningful inefficiency should be addressed?** Prioritize engineering impact over style. This is a read-only review: do not edit files, fix findings, stage, commit, merge, rebase, push, or reset.

## Scope and investigation

1. Honor an explicit review target: files, staged or unstaged changes, a commit or range, a branch comparison, or an orchestrator's integrated result. Otherwise inspect Git status and choose the narrowest coherent current change. If staged changes exist, use them as the initial boundary; distinguish any unstaged or untracked changes that affect interpretation. Read the contents of in-scope untracked files. State the chosen scope. Ask only when no safe boundary can be inferred.
2. Read repository guidance, the relevant diff, and enough surrounding code to understand the intended behavior. Trace callers, contracts, data flow, persistence, state, and lifecycle where the changed path requires it. Avoid unrelated code except where needed to establish impact.
3. Inspect relevant tests and run cheap targeted validation when useful. Do not repeat expensive validation already performed by the caller. Passing tests do not replace behavioral analysis. Never change code to make validation pass.
4. Evaluate correctness, data integrity, security, regressions, reliability, concurrency, resources, and performance; then important test gaps. Use [review checks](references/review-checks.md) when the change involves a risk-heavy path or the impact is unclear. Do not manufacture findings.

## Evidence and classification

Every defect finding needs the affected code, a plausible trigger, observable impact, and why the behavior is wrong or risky. State any unverified assumption. Severity reflects impact and likelihood: **P0** critical severe harm, **P1** significant issue that normally blocks integration, **P2** real issue with limited scope or less common trigger, **P3** minor concrete issue.

Report missing test coverage only when it leaves important changed behavior meaningfully exposed to regression. Use P0-P3 based on the impact and likelihood of the regression the missing test would fail to detect; do not create a separate `[Test]` classification. Do not request generic extra tests without concrete changed behavior that needs protection.

For a performance regression, explain what became more expensive, how this diff causes it, the workload where it matters, the affected resource, and a likely improvement. Use **[Perf]** only for a meaningful optimization opportunity that is not a defect or regression. Do not turn theoretical speedups or micro-optimizations into findings; distinguish static analysis from measurements.

## Report

Put defect findings first, ordered by severity, then `[Perf]` opportunities. Format each as `[P1] Title` or `[Perf] Title`, followed by `path/to/file:line-range` and a concise explanation of trigger, impact, evidence, and correction direction when useful. After findings, briefly report validation, material uncertainty, and an overall summary. If there are no meaningful defects or optimization opportunities, say **No significant findings.**

Work directly without subagents or worktrees for normal reviews. For exceptionally large, cleanly partitioned reviews, delegate only when the value justifies the extra usage. In an `$orchestrate-engineering` workflow, review the integrated result against the original goal and return findings to the parent; the parent handles fixes and integration. Never invoke `$commit` automatically. A later request to fix findings is a separate implementation task.
