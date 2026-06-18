# Design Decisions — v2 & v3 Architecture
## The Praeceptor

> Maps structural changes to their source concept in:
> **Van Clief & McDermott, "ICM-Folder-Structure-as-Agentic-Architecture" (arXiv:2603.16021)**

---

## The Core Insight from the ICM Paper

Claude Projects are not just knowledge bases — they are **Interpretable Context Methodologies (ICMs)**. Folder position carries cognitive meaning. Different layers serve different roles. Mixing them degrades output.

| Layer | Role | Should contain |
|-------|------|----------------|
| L0 — Identity | Who the agent is | Fixed character, expertise, limits |
| L1 — Routing | Where inputs go | Load order, session type routing |
| L2 — Task contract | How each task executes | Per-mode execution specs |
| L3 — Reference (stable) | Stable constraints | Frameworks, voice, character |
| L4 — Working (per-run) | Per-session data | KNOWING layer, session logs |

---

## Decision 1: Extract Load Order and Session Routing from `icm/CLAUDE.md` into `routing.md`

**v1 behavior:** `icm/CLAUDE.md` contained the load order (L1 routing), instructions for first vs. subsequent sessions (L1 routing logic), and Rule 0 (L3 behavioral constraint). A single file served as setup guide, routing logic, and character rule.

**v2 change:**
- `routing.md` — L1 only: Step 0 (guardrails), Step 1 (character load order), Step 2 (session type table), Step 3 (KNOWING layer currency), standing rules
- `icm/CLAUDE.md` — preserved as session setup guide and L0/L2 reference. Pointer to routing.md added.

**ICM source:** L1 (routing) must be distinct from L0 (identity). The load order is routing logic — it determines what context is loaded and in what sequence. Embedding it in the same file as character identity makes it appear to be part of the character. It is not. It is the loading sequence.

**What this fixes:** A cold-start session reading `icm/CLAUDE.md` had to parse what was "instructions for this Claude Project" vs. "who this character is." In v2, the routing sequence is in `routing.md` (load this, then this, then this) and the character is in `icm/identity.md` (this is who he is).

---

## Decision 2: Add L2 Session-Mode Task Contract (`_modes/session-mode.md`)

**v1 behavior:** `icm/intake/protocol.md` was a well-constructed L2 contract for the intake session. Active sessions (existing KNOWING layer) had no explicit task contract — the session was governed by character alone, with no structural slots for confidence level, guardrail checks, or session close format.

**v2 change:** `_modes/session-mode.md` — explicit execution contract for active sessions: pre-session checklist, session open format, guardrail hooks throughout, KNOWING layer update at close, session log entry.

**ICM source:** Context Layer 2 (task contract). The paper distinguishes L2 from L0 (identity) and L3 (constraints): L2 is the execution contract for a specific mode. The intake protocol was an excellent proto-L2. The active session needed the same.

**What this fixes:** Active sessions in v1 were character-only — no pre-session checklist, no confidence level assessment, no structured close. v2 adds session-level structure without constraining character expression. The session body has no output contract — he engages as himself. But the session open, close, and guardrail hooks are explicit.

---

## Decision 3: KNOWING Layer as L4 Working State (Already Correct in v1)

**v1 behavior:** The KNOWING layer (JSON object per person, ≤800 tokens) was the per-person working state — updated at session close, provided at session start. This is precisely Context Layer 4 — per-run data that changes every session.

**v2 assessment:** The KNOWING layer architecture was correct in v1. It needed no changes. The DESIGN_DECISIONS entry exists to make the ICM mapping explicit: KNOWING = L4. This is one of the strongest architectural decisions in the v1 portfolio.

**ICM source:** Context Layer 4 (working/per-run data). The KNOWING layer is the most elegant L4 implementation in any of the five repos — structured, token-efficient, per-person, auto-updated at session close. The per-person state management (pasting JSON at session start, outputting updated JSON at close) is a correct and efficient L4 loop.

**What was missing:** A session-level calibration log (`_sessions/_calibration_log.md`). The KNOWING layer tracks per-person state. The calibration log tracks system behavior across all persons and sessions — a different signal.

---

## Decision 4: `_guardrails/domain/coaching-guardrails.md` — Safety Before Rule 0 (v3)

**v1+v2 behavior:** `icm/voice/refusals.md` contained character-level refusals — what The Praeceptor will not do because of who he is. These are correct L3 character rules. They are not safety guardrails. The distinction matters:
- **Character refusals** (refusals.md): "I won't be a cheerleader. I won't validate choices without examining them." — These are about character integrity.
- **Safety guardrails**: "I won't continue if you're in crisis. I'll direct you to professional help." — These are about user safety.

v1 had character refusals but not safety guardrails.

**v3 change:** `_guardrails/domain/coaching-guardrails.md` — 5 escalation triggers that override Rule 0:
- Crisis signals (suicidal ideation, self-harm)
- Medical symptoms
- Legal advice
- Financial advice
- Relationship safety

**ICM source:** Layer 3 stability principle. Character refusals are L3 stable constraints about how the mentor behaves. Safety guardrails are a different type of L3 constraint — they govern what professional escalation is required regardless of character. Placing safety in `_guardrails/` makes it load-order enforced and explicit.

**The Rule 0 interaction:** Rule 0 is "does this make The Praeceptor more himself, or more responsive to the user's surface?" Rule 0 correctly governs character consistency. But Rule 0 does not apply to safety escalation — a crisis response is not about character consistency, it is about user safety. The explicit statement "guardrails override Rule 0" prevents a failure mode where a strong character rule suppresses a necessary safety escalation.

---

## What Didn't Change

- `icm/identity.md` — cleanest L0 in the portfolio. Composite methodology, explicit synthesis, clear character. No changes.
- `icm/rules.md` — clean L3 behavioral contract. No routing logic embedded.
- `icm/voice/` — complete L3 character layer (signature-questions, blind-spots, failure-stories, refusals). All correctly scoped. No changes.
- `icm/intake/protocol.md` — proto-L2 intake contract. Functionally correct. No changes.
- `icm/reference/` — timeless mentor source extractions. Correctly placed as L3 stable reference. No changes. No time-sensitive data in this folder.

The Praeceptor v1 was the strongest character design in the portfolio. v2+v3 add structure without touching the character.

---

*Reference: Van Clief & McDermott, "ICM-Folder-Structure-as-Agentic-Architecture" (arXiv:2603.16021)*
*v2+v3 built: 2026-06-17*
