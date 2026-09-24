# Personal skills

Each folder under `skills/` containing `SKILL.md` is a skill. On Windows, link your user-level skills directory to this repository once. After that, `git pull` updates existing skills and makes new skill folders available without rerunning a script. Codex reads user skills from `~/.agents/skills`.

Clone this repository to a permanent local path, then run this from PowerShell in the repository folder:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\link-skills.ps1
```

The script creates a directory junction from `~/.agents/skills` to this repo's `skills/` directory. It does not change `~/.codex/skills` or its managed `.system` folder. The temporary `ExecutionPolicy Bypass` setting applies only to that PowerShell process.

## Existing skills directory

If `~/.agents/skills` is already a junction to this repo, the script leaves it alone. If it is an ordinary directory, the script skips it by default. To migrate it, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\link-skills.ps1 -Migrate
```

Migration moves the existing directory to a sibling `.skills.backup-...` folder, then creates the junction. Review and remove the backup yourself when ready. A link pointing elsewhere is never replaced automatically.

For another tool with a different skills directory, specify its path with `-Destination`. Keep this checkout at the same local path, because moving it breaks the junction. Windows junctions cannot target network shares.

To add a skill, put its whole folder in `skills/` with a `SKILL.md` and commit it. On another computer, `git pull` is enough to update the linked directory. Start a new Codex session if a newly added or changed skill does not appear immediately.
