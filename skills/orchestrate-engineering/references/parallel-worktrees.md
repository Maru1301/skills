# Parallel implementation with Git worktrees

Use this protocol only when at least two implementation tasks are independent enough to run concurrently and isolation provides a real benefit. A worktree prevents checkout collisions; it does not remove task dependencies or semantic conflicts.

## Prepare

1. Inspect the target branch, `HEAD`, worktree list, uncommitted and untracked files, and any existing task branches. Establish which committed revision each task needs. Do not stash, reset, clean, overwrite, or move user changes merely to make a worktree possible.
2. Check that tasks have distinct ownership or a clear shared-interface contract. If a prerequisite changes an interface or schema needed by another task, finish and integrate that prerequisite first, then base dependent work on it.
3. If relevant source changes exist only in the primary working tree, decide whether they can be safely carried into isolated worktrees without altering the user's checkout. If not, work sequentially or ask for the missing decision; do not let agents implement against stale code.

## Isolate and execute

1. Choose predictable, collision-free temporary names derived from the goal and task, such as `codex/<goal>-<task>` for a branch and a matching temporary worktree directory. Create one branch and worktree per independent implementation task from the correct committed base. Record their paths and starting revisions.
2. Assign exactly one implementation subagent to each worktree. The assignment must state the worktree path, branch, permitted scope, dependencies, acceptance criteria, validation expectations, and the requirement for a clean commit before reporting completion. The parent and other agents must not write into that worktree concurrently.
3. Collect each commit ID and inspect its diff, tests, and reported caveats. Confirm the branch still contains the expected task result and no unrelated edits. Failed or partial tasks remain isolated until repaired or deliberately abandoned with their work preserved.

## Integrate and recover

1. Integrate accepted commits in dependency order. If the target branch is already checked out in a dirty primary worktree, do not try to check out that branch in another worktree. Instead, create a temporary integration branch from its committed HEAD in a separate worktree, integrate and validate there, and preserve the primary checkout. Move the validated result onto the intended target branch only when that checkout can be updated safely; until then, report an integration candidate, not a completed target-branch integration. Keep the mapping from source commits to integrated commits when cherry-picking changes commit IDs.
2. Resolve conflicts in the integration checkout. Review shared interfaces, migrations, generated artifacts, behavior, and tests for semantic conflict. Re-run checks on the integrated result, not only in individual worktrees.
3. If integration or validation fails, keep the branches and worktrees until the issue is corrected or the user chooses a recovery path. If the target branch advances while agents work, re-evaluate bases and dependencies before integrating.
4. Clean up only after the final result is validated and every task change has been accounted for in the target branch. Confirm there is no unique uncommitted or unintegrated work before removing a worktree or deleting its branch. Preserve evidence and report what remains when cleanup cannot be done safely.
