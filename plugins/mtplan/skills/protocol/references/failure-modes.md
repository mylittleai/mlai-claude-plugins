# Failure Modes and Mitigations

Real failures observed across 50+ commits in multi-phase projects, not hypotheticals.

## Failure: Batched Checkbox Updates

**What happened:** Agent completed 6+ items but updated PLAN.md only at session end. After context compaction mid-session, PLAN.md showed items as pending that were already done. Agent re-proposed completed work, wasting an entire session on remediation.

**Root cause:** No explicit rule requiring atomic updates. The agent naturally batched for efficiency.

**Mitigation:** Atomic checkpoint discipline (ADR-0002). "Check off each item immediately upon completion, in the same logical step as the work. Never batch."

**Evidence:** After switching to atomic updates, no checkpoint drift occurred across 8 subsequent phases and 14 context compactions.

## Failure: Direction-Seeking at Phase Boundaries

**What happened:** All phase items were complete. Instead of entering plan mode for the next phase, the agent asked "what should I do next?"

**Root cause:** Ambiguity about what "each phase requires explicit direction" meant. The agent interpreted it as "ask the user before starting anything."

**Mitigation:** Phase execution model (ADR-0007). "Each phase requires explicit direction" means plan-mode transitions, not individual items. At phase completion: enter plan mode, do not ask "what should I do?"

## Failure: Ad-Hoc State Files

**What happened:** Agent created an undocumented tracking file (e.g., `docs/backlog.md`) to capture observations. This file was not read by the bootstrap protocol, so its contents were lost after compaction.

**Root cause:** No specification of where observations should go. The agent improvised.

**Mitigation:** Deferred Decisions section in PLAN.md (ADR-0012) is the designated home. Anything outside the two-file system is invisible to the bootstrap protocol.

## Failure: Tasks Tool as Program Counter

**What happened:** Claude Code Tasks were created to mirror PLAN.md items. They became noisy, were never consulted for state recovery, and added bookkeeping overhead without value.

**Root cause:** Tasks do not persist across sessions. They cannot be read by the bootstrap protocol.

**Mitigation:** Tasks demoted to parallelism tracker only (ADR-0011). Sequential progress tracked exclusively by PLAN.md + STATE.md.

## Failure: STATE/PLAN Atomicity Divergence

**What happened:** STATE.md and PLAN.md checksums diverged when work was completed but files were not updated in the same commit. After compaction, state showed "in progress" for work that plan showed as "not started."

**Root cause:** Files updated independently rather than atomically.

**Mitigation:** Both files updated in the same commit (ADR-0002). Stop hook blocks session end if STATE.md is stale (ADR-0004).

## Failure: Silent Pipeline Continuation After Tool Failure

**What happened:** An external API quota was exhausted mid-pipeline. The pipeline continued with zero useful input, producing garbage output. The user had to manually interrupt.

**Root cause:** No detection of tool failures within agent message streams.

**Mitigation:** Detect tool failures from message format, distinguish partial vs complete failure, fail fast with clear error message rather than continuing with degraded state.

## Failure: Stale State at Session End

**What happened:** Agent ended session without updating STATE.md. Next session started with stale state from the previous session, leading to confusion about what was in progress.

**Root cause:** No enforcement of STATE.md currency at session boundaries.

**Mitigation:** Blocking stop hook (ADR-0004). Hook exits with code 2 if STATE.md not modified in last 10 minutes and PLAN.md has unchecked items. Includes loop-prevention guard.
