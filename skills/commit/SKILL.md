---
name: commit
description: Inspect current Git changes, select a coherent commit boundary, write a diff-grounded message, and create a commit. Use for commit requests, not implementation or code repair.
---

# Commit current work

Make a commit only from changes that belong together. Invocation authorizes the commit; ask only when the boundary cannot be chosen safely. Do not edit source files, fix validation failures, push, amend, merge, or manage worktrees.

1. Confirm the repository and current worktree. Inspect `git status`, `git diff --cached`, `git diff`, untracked files and their contents as appropriate, and recent subjects when they reveal a reliable convention. Inspect the actual diff before deciding scope or message. If there is nothing to commit, stop without an empty commit.
2. Identify the change's intent and a coherent boundary. Treat already staged changes as the primary intended set. Do not automatically add unstaged changes to it. Exclude unrelated, suspicious, generated, accidental, or secret-bearing files. If staged material itself mixes concerns or contains a suspected secret, pause for a boundary decision rather than silently changing the user's staging. In an unstaged tree, stage only clearly related paths or hunks; never use broad staging when unrelated changes may exist. Preserve all excluded changes.
3. Prefer one logical commit. Keep implementation, tests, configuration, and documentation together when they serve that change. When separate changes have clear boundaries and the request covers them, create separate atomic commits; ask if the boundary is uncertain. Before each commit, inspect the exact staged diff and status again.
4. Run cheap, relevant existing validation if useful. Avoid repeating expensive checks already completed by the caller. Do not change code to repair failures; report failures or unavailable validation and decide whether a commit remains appropriate.
5. Follow a reliably established repository message style for the subject. Otherwise use an imperative Conventional Commit subject, `type(scope): summary` or `type: summary`, with a type that reflects the diff. Include a body with every commit: in a few short lines or bullets, explain the concrete changes and their effect or purpose as supported by the diff. Mention meaningful validation or limitations when relevant. Keep detail proportional to the change; do not pad, repeat the subject, or invent scopes, issue IDs, breaking changes, or motivations. Create the commit and verify its hash, full message, committed scope, and remaining status.

Never discard changes, reset unrelated work, use destructive Git commands, force push, push automatically, or amend without an explicit request. Do not include secrets or credentials. If committing only a subset of staged content cannot be done safely while preserving other staged and unstaged changes, ask the user.

In an orchestrated task, operate only in the assigned worktree and commit only that task. Return the hash to the parent; leave branch integration and worktree cleanup to the parent. Work directly without subagents or new worktrees.

Report the commit hash, message, committed scope, validation performed, and any remaining uncommitted changes. If no commit was created, state why.
