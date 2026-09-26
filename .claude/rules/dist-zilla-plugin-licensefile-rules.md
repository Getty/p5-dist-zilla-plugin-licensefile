# Dist-Zilla-Plugin-LicenseFile House Rules

Apply to every task in this distribution unless explicitly overridden. Bias: caution over
speed on non-trivial work; use judgment on trivial tasks. Loaded automatically at launch
(same priority as `CLAUDE.md`). Subagents get their discipline from the skills
force-loaded via `briefing.skills` — this file is for the orchestrating agent.

## Engineering discipline

1. **Think before coding** — state assumptions; when uncertain, ask rather than guess.
   Push back when a simpler approach exists.
2. **Simplicity first** — minimum code that solves the problem. Nothing speculative.
3. **Surgical changes** — touch only what you must. Match existing style.
4. **Goal-driven execution** — define success criteria, loop until verified.
5. **Surface conflicts, don't average them** — pick one (more recent / more tested), flag
   the other for cleanup. Don't blend.
6. **Read before you write** — the plugin and the command share three class methods; a
   change to `filename`/`wanted_text`/`comparable` reaches both halves at once.
7. **Tests verify intent, not just behavior** — a test that can't fail when the logic
   changes is wrong. Reproduce a bug before fixing it; leave the regression behind.
8. **Checkpoint after every significant step** — summarize: done / verified / left.
9. **Match conventions** — conformance > taste. Surface a harmful convention; don't fork.
10. **Fail loud** — "Done" is wrong if anything was skipped. "Tests pass" is wrong if any
    were skipped.
11. **A red test is a claim before it is a failure** — before turning a test green, say
    what it asserts and whether your fix keeps that claim or replaces it. If the claim is
    wrong, fix the claim and say so.

## Delegation

This rule depends on whether the Agent/Task tool is available to you.

- **You can spawn subagents** (orchestrating main agent): Do NOT touch behavior-relevant
  code yourself — delegate. Your lane: coordinate, inspect, plan, review diffs, run
  tests, edit non-behavioral docs. When in doubt, delegate. Why: only the
  `dist-zilla-plugin-licensefile-*` agents get their skills force-loaded via
  `briefing.skills`; you get no briefing and would touch internals with too little
  context.

  | Task | Agent |
  |---|---|
  | Implement / refactor / debug the plugin, the command, cpanfile | `dist-zilla-plugin-licensefile-worker` (default) |
  | Commits, `Changes`, card → done, pre-release audit | `dist-zilla-plugin-licensefile-release-manager` |

- **You cannot spawn subagents** (you ARE a `dist-zilla-plugin-licensefile-*` agent): the
  delegation lock does not apply to you — implement, refactor, debug and test per these
  rules.

Behavior-relevant = the `munge_files` check and its messages, the `dzil genlicense`
command, the shared `filename`/`wanted_text`/`comparable` class methods, the `required`
attribute, `cpanfile`, and tests. Pure prose docs and `Changes` notes are not.

## Coordination — karr board (always in scope)

Ticket coordination is the orchestrating agent's job, so `karr` is always in scope —
don't invoke the `kanban-issues-karr-coordination` skill first, just use it. Git-native kanban;
state lives in `refs/karr/*`; one board, this repo. Day-to-day: `karr list --compact` /
`karr board` for open work; `karr show ID` for detail; `karr create/edit/move/handoff`
for the usual flow; mutating commands auto-sync. Full surface: skill
`kanban-issues-karr-coordination`.

Cross-repo work is a ticket on the *other* repo's board (`cd
../p5-dist-zilla-pluginbundle-author-getty && karr create …`), never a direct edit there.

**Serialize board mutations when fanning out.** Keep implementation parallel if you like,
but collect results and loop `karr move`/`handoff`/`sync` sequentially — N landing at
once is a resource event, not a cheap command.

## Release — never without permission

`prove -l t/`, `dzil build` and `dzil test` are fine anytime. `dzil release` and any CPAN
upload are STRICTLY forbidden without the maintainer's explicit go-ahead — even if
`Changes` or a plan names "release" as the next step. For anything heading toward release:
stop and ask.

## Repo-specific hazards

- **The committed `LICENSE` holds the bare `->license`, never `->fulltext`.** The
  copyright notice `fulltext` prepends makes GitHub report `NOASSERTION` instead of the
  real licence — verified against the live API. Detection is the whole reason the file is
  committed, so "fixing" it back to `fulltext` silently defeats the distribution. The
  rationale is in skill `dist-zilla-plugin-licensefile-core`.
- **The plugin checks, the command writes — never the reverse.** The plugin never writes
  anything; the command never checks at build time. Keep the split on that line.
- **`comparable` forgives trailing whitespace only.** A mismatch is the signal the check
  exists to raise; do not widen the normalisation to make a failing build pass.
- **`required = 0` logs, it does not skip** the check. A downgraded check still complains
  on every build.
- **`[Bootstrap::lib]` in `dist.ini` is deliberate** — this dist runs the plugin it
  defines, so the plugin must load from `lib/`, not from what is installed. A green
  `dzil build` here is exercising the plugin against itself.
- **`@Author::GETTY` in `../p5-dist-zilla-pluginbundle-author-getty` constructs this
  plugin.** An attribute or shared-class-method rename is a coordinated change: verify
  that bundle, or file a ticket on its board before landing.

## Perl specifics — reference, don't restate

Module loading, `$VERSION`, cpanfile pinning and house style: skills `getty-perl-core`,
`getty-perl-moose` (the plugin class), `getty-perl-distribution`. `[@Author::GETTY]`, POD
weaving, `{{$NEXT}}`: skill `getty-perl-release-author-getty`. dist.ini mechanics:
`perl-release-dist-ini`. Commits: only `dist-zilla-plugin-licensefile-release-manager` commits (it carries `getty-git-commit-style`). Architecture and the
shared-contract invariants: `dist-zilla-plugin-licensefile-core`. Don't duplicate any of
it here.
