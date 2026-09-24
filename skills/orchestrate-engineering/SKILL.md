---
name: orchestrate-engineering
description: Orchestrate multi-step software engineering work across a repository, including dependency-aware delegation, isolated parallel implementation, integration, and final validation. Use a direct workflow for simple changes.
---

# Orchestrate engineering work

Own the user's goal from investigation through validated integration. Use the smallest workflow that safely completes it: **start cheap, delegate selectively, escalate when justified**. The parent agent remains accountable for scope, decisions, integration, and the final result; subagents own only assigned tasks.

## Choose the execution shape

1. Clarify only material ambiguity. Inspect repository instructions, current branch and working-tree state, relevant code, architecture, tests, and available tools. Distinguish an implementation request from an analysis-only request before editing.
2. Define the desired outcome and a practical acceptance check. For complex work, identify tasks, their outputs, file or interface boundaries, and prerequisite edges. A task may start only when its required inputs exist. Reassess the graph when an investigation changes those assumptions.
3. Choose one of these paths:
   - **Simple:** inspect, implement directly, validate. Do not create a subagent or worktree just to follow a process.
   - **Dependent work:** execute prerequisite tasks in order; delegate only when a bounded investigation or implementation provides clear value.
   - **Independent work:** parallelize only genuinely independent tasks when doing so provides meaningful wall-clock or context-management benefit. Prefer the parent doing straightforward analysis itself. Parallelize implementation only when task boundaries and repository state permit safe isolation. Read [parallel-worktrees.md](references/parallel-worktrees.md) before creating implementation worktrees; handle small changes directly without one.

## Route worker capability

Select a model and reasoning effort for each delegated task from the capabilities currently available, not from a fixed model-name list. Parallelism does not imply that every worker needs maximum capability. Prefer medium reasoning for normal orchestration and implementation, low reasoning for simple exploration or mechanical work, and high reasoning only when complexity, ambiguity, repeated failure, or integration risk warrants it.

| Tier | Suitable work | Preferred capability |
|---|---|---|
| Lightweight worker | Delegated repository exploration; locating files, symbols, usages, or references; fact collection; read-only investigation; mechanical work; simple validation | Fast, cost-efficient model with low reasoning when sufficient, otherwise medium |
| Standard implementation worker | Well-scoped implementation, isolated bug fixes, tests, and straightforward refactoring with clear acceptance criteria | Capable coding model with medium reasoning; default for implementation subagents |
| Complex reasoning worker | Cross-module or architectural work, ambiguous bugs, concurrency, complex refactoring, high coupling, or substantial integration risk | Strongest appropriate coding/reasoning model with high reasoning |

The parent owns decomposition, dependencies, delegation, integration strategy, semantic conflict detection, and final validation. Use medium reasoning as the normal starting point; prefer a strong reasoning-capable parent with high reasoning when orchestration is clearly complex or high-risk. Optimize in this order: correctness, recoverability, appropriate capability, then execution efficiency. If only one model is available, vary supported reasoning effort. If the invocation cannot control model or reasoning, treat routing as advisory and never claim a setting was applied.

## Delegate with explicit contracts

Do not spawn a subagent unless delegation provides clear value beyond the parent doing the work. Prefer a few well-scoped capable workers over many speculative ones; do not ask multiple agents to solve the same problem independently unless the user requests it or significant uncertainty warrants it. Give each agent a narrow objective, expected output, acceptance criteria, repository instructions, prerequisite results, ownership boundaries, chosen worker tier, and a reporting format. Set model and reasoning overrides only when the invocation supports them; otherwise use the task contract to supply the needed context. For concurrent implementation, assign one branch and one worktree per subagent; tell it to run every file operation and build in that worktree and to avoid the primary checkout and other worktrees. Require a clean commit from each worktree assignment before reporting completion. Do not start dependent tasks while their prerequisites are unfinished.

Require structured reports. An implementation subagent reports its completion status and task output; branch and worktree used (or none); commit hash when it produced a commit; files changed; validation performed and its result; assumptions; discovered dependencies; and unresolved issues or risks. A read-only investigator reports findings, relevant files or symbols, supporting evidence, uncertainties, and a recommended next action when useful. The parent checks these reports and the underlying work, not just a success label.

The parent tracks progress, resolves cross-task decisions, and can stop or retask work when a new dependency or conflict appears. If subagents or safe worktrees are unavailable, continue sequentially rather than simulating parallel writes in one checkout. A moderate task may benefit from one implementation subagent; a simple change needs none.

## Escalate and recover delegated work

Worker routing is provisional. Ask a subagent to report when assumptions prove wrong, hidden dependencies or unexpected coupling appear, scope expands, tests fail for non-obvious reasons, attempts repeat without progress, several architectural approaches become plausible, semantic correctness becomes hard to establish, or the cost of a wrong choice rises. Start at the least costly tier adequate for the known task; choose higher capability at the outset only for clearly high-risk work. Otherwise move from lightweight to standard to complex capability, or from low to medium to high reasoning, only when the current level proves insufficient and the invocation supports a change. Do not repeat essentially the same failed approach at the same capability level.

When a subagent fails, first diagnose whether the cause is insufficient context, poor decomposition, a hidden dependency, insufficient capability, an environment or tool failure, invalid assumptions, or implementation difficulty. Then add context, revise boundaries or the dependency graph, escalate capability, serialize formerly parallel work, retry with a changed approach, or stop and report the blocker. Preserve failed worktrees containing useful diagnostics or implementation. Do not immediately spawn a replacement to repeat the same task.

## Integrate and validate

Review each completed task against its contract before integration. Do not integrate an incomplete task or one with failing required checks without resolving or explicitly accounting for the failure. Bring accepted commits into the target branch in dependency order; resolve textual and semantic conflicts centrally. Check interactions between components even when Git reports a clean merge. Run the repository-appropriate build, tests, lint, static analysis, or other checks, then compare the integrated behavior with the original goal and acceptance criteria. Do not call the work complete merely because child tasks passed independently or commits merged.

When the repository changes underneath the work or implementations prove incompatible, pause affected integration, preserve recoverable state, revise the dependency graph and task contracts, then retry or finish the remaining work directly. Apply the failure diagnosis above to failed subagent work. Report any work that cannot be safely integrated or validated.

After successful integration and validation, remove only temporary worktrees and branches whose work is safely present in the target result. Preserve anything with unintegrated commits or uncommitted changes. Never discard user changes, reset unrelated work, force-push, or rewrite user history without explicit authorization.
