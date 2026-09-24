# Personal skills

Each folder under `skills/` containing `SKILL.md` is a skill. Clone or download this repository on a Windows computer, then run the installer from PowerShell in the repository folder:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

By default, skills are copied to `~/.agents/skills`. The installer copies the complete skill folder, including any `references` or other supporting files. It leaves an existing installation alone unless you request an update.

```powershell
$installer = '.\install.ps1'
powershell -NoProfile -ExecutionPolicy Bypass -File $installer -List
powershell -NoProfile -ExecutionPolicy Bypass -File $installer -Skill orchestrate-engineering
powershell -NoProfile -ExecutionPolicy Bypass -File $installer -Target Codex
powershell -NoProfile -ExecutionPolicy Bypass -File $installer -Target Both
powershell -NoProfile -ExecutionPolicy Bypass -File $installer -Destination 'D:\My Skills'
powershell -NoProfile -ExecutionPolicy Bypass -File $installer -Update
```

The temporary `ExecutionPolicy Bypass` setting applies only to that PowerShell process. You can omit it if your system already permits local scripts.

`-Update` saves each previous copy next to the installed skill in a hidden-looking folder named `.skill-name.backup-...`. Remove a backup yourself after confirming the new skill works. Restart your agent or begin a new session if it does not immediately detect an installed skill.

To add another skill to this repository, copy its whole folder into `skills/` and ensure it contains `SKILL.md`. The installer will discover it automatically.
