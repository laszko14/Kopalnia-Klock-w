# AGENTS.md — Kopalnia Klocków

Agent instructions for this repository. User instructions and verified source code have priority over stale chat summaries. This file is not authorization for releases, purchases, credentials, destructive changes or unrelated refactoring.

## Project scope from user decisions
- Android idle/automatic mining game named **Kopalnia Klocków**.
- Visual direction: smooth cartoon style, not pixel art.
- Gameplay is primarily automatic, not a tap-to-mine loop.
- Mines are divided into worlds/mines rather than one infinite tower.
- **First mine has 30 floors. Maximum upgrade level of each floor is 800.**
- The user wants a rich economy including coins, crystals and rare rewards; exact balance must be specified and tested instead of invented as a finished implementation.

These are design constraints, NOT claims that these features have been coded.

## Read first
1. Inspect current repository tree, branch, commit history and any existing README, design docs, build files and CI before planning changes. See `PROJECT_STATUS.md` for recorded facts and unknowns, and update it with verified evidence when working on this project.
2. Use the actual build system and commands found in the repository. Never assume Gradle, an Android package name, a signing setup or CI exists without checking.
3. For a long-running task, reconstruct unfinished work from the current diff, CI logs and code. Never discard existing commits or user changes.
4. Keep documentation organized: stable rules in this file, features in focused `docs/` specs, volatile progress in `PROJECT_STATUS.md`.

## Workflow quality bar
- Before coding, state a bounded goal, acceptance criteria and exclusions.
- Bugs: reproduce/gather logs, isolate root cause, compare good/bad paths, test one hypothesis, then make a minimal fix.
- Features: design behavior, write relevant tests where practical, implement minimally, inspect regressions and review the diff.
- Test and build using verified repository commands; for UI/gameplay also verify on Android device/emulator if possible and clearly disclose if not.
- Develop on a feature branch; propose a scoped PR. Never claim an APK or successful test without current supporting evidence.
- Keep signing material, API tokens and user data out of the repository.

## Six reusable ChatGPT/Work/Codex routines
1. **Project context:** rely on checked-in docs and verified code instead of assumptions from another conversation.
2. **Work:** use authorized app/browser tools for multi-step tasks; report actual outputs and blockers.
3. **Codex:** systematic debugging, test-driven steps when appropriate, review and verification before completion.
4. **Skills/Plugin Creator:** reuse skills for procedures; keep feature-specific rules in this repository.
5. **Automations:** only schedule reminders or monitoring when explicitly requested; preserve schedule and timezone.
6. **MCP/Apps SDK:** prefer connected trusted tools; validate credentials, permissions and current official APIs before integrations.

## Session handoff
Report Goal; Current status; Completed (with evidence); Validation performed and not performed; Next steps; Risks/blockers; Source files/commit/PR. Update `PROJECT_STATUS.md` when the task includes actual project changes.

Do not claim the project is finished merely because the instructions exist.
