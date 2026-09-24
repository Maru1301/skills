# Personal skills

Each folder under `skills/` containing `SKILL.md` is a skill. On Windows, create directory junctions from your user-level skill directories to this checkout. After setup, `git pull` updates the linked skill files without reinstalling them.

Clone this repository to a permanent local path, then run this from PowerShell in the repository folder:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\link-skills.ps1
```

By default, junctions are created in `~/.agents/skills`. Each junction points to the complete skill folder in this repository, including its `references` and other supporting files.

```powershell
$linker = '.\link-skills.ps1'
powershell -NoProfile -ExecutionPolicy Bypass -File $linker -List
powershell -NoProfile -ExecutionPolicy Bypass -File $linker -Skill orchestrate-engineering
powershell -NoProfile -ExecutionPolicy Bypass -File $linker -Target Codex
powershell -NoProfile -ExecutionPolicy Bypass -File $linker -Target Both
powershell -NoProfile -ExecutionPolicy Bypass -File $linker -Destination 'D:\My Skills'
```

The temporary `ExecutionPolicy Bypass` setting applies only to that PowerShell process. You can omit it if your system already permits local scripts.

## Existing skills

If a skill is already linked to this checkout, the script leaves it alone. An existing ordinary directory or a link to another location is skipped by default. To migrate existing ordinary skill directories, use `-Migrate`:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\link-skills.ps1 -Target Both -Migrate
```

Migration moves each existing ordinary directory to `.skill-name.backup-...` beside the new junction, then creates the junction. It does not replace links pointing elsewhere. Check and remove backups yourself when ready. Each destination is handled separately.

Keep the checkout at the same local path; moving it breaks the junction targets. Junctions cannot point to network shares. After `git pull`, start a new agent session if updated skill instructions are not detected immediately.

To add another skill, put its whole folder in `skills/` with a `SKILL.md`, then rerun `link-skills.ps1` to create its junction.
