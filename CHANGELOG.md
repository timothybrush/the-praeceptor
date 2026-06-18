# Changelog — The Praeceptor

## v3.0 — 2026-06-17 — Guardrails Layer

Adds a structural safety layer. Coaching guardrails are now load-order enforced and explicitly override Rule 0 when safety is at stake.

### Added

- `_guardrails/shared/output-disclaimers.md` — required disclaimers on all output
- `_guardrails/shared/confidence-floor.md` — confidence levels; hard STOP conditions
- `_guardrails/shared/escalation-triggers.md` — professional escalation gates
- `_guardrails/shared/adversarial-input-flags.md` — one-sided input detection
- `_guardrails/domain/coaching-guardrails.md` — 5 escalation triggers (suicidal ideation/crisis, medical symptoms, legal advice, financial advice, relationship safety) + 5 input flags (catastrophizing, seeking validation, full external attribution, urgency bypass, conflating coaching with therapy)
- `routing.md` Step 0: load all guardrails before character files

### Changed

- `icm/CLAUDE.md` — Step 0 guardrails pointer added to Load Order
- `_modes/session-mode.md` — Professional Required block added; Rule 0 override note explicit
- `routing.md` — guardrails cannot be overridden by Rule 0 (stated explicitly)

### Design note

The explicit "guardrails override Rule 0" statement is intentional. Rule 0 is a character integrity rule — it governs whether a response serves the mentor's character or the user's surface preference. Guardrails are safety rules — they govern whether a response escalates a clinical, legal, or safety situation to professionals. These are orthogonal. Rule 0 does not protect against safety escalation requirements.

---

## v2.0 — 2026-06-17 — ICM Architecture Upgrade

Applies the Interpretable Context Methodology (ICM) framework from Van Clief & McDermott (arXiv:2603.16021).

### Added

- `routing.md` — L1 routing extracted from `icm/CLAUDE.md`: Step 0 (guardrails), Step 1 (load order), Step 2 (session type routing: intake vs. active), Step 3 (KNOWING layer currency check), standing rules
- `_modes/session-mode.md` — explicit L2 task contract for active sessions (existing KNOWING layer)
- `_sessions/_calibration_log.md` — L4 session outcome tracker

### Changed

- `icm/CLAUDE.md` — Step 0 pointer added to Load Order section

### Structural Changes Summary

| v1 location | v2 location | Reason |
|-------------|-------------|--------|
| Load order in `icm/CLAUDE.md` | `routing.md` Steps 1–2 | L1 routing separated from L0/L2 |
| Session type routing implied | `routing.md` Step 2 | Made explicit in routing table |

### Note on icm/ structure

The `icm/` folder is a well-structured v1 — identity.md is clean L0, rules.md is clean L3, voice/ is clean L3 character layer, intake/ is clean L2 intake contract, reference/ is clean L3 (timeless mentor source extractions). No changes needed to any of these files. The only gap was missing L1 routing and missing guardrails layer.

---

## v1.0 — 2026-05 — Initial Release

Built for the Jeff van Clief Skool community (Week 5).

**What it did well:**
- Cleanest L0 identity in the v1 portfolio — composite of named mentors with explicit synthesis methodology
- Rule 0 — character integrity rule that actively resists user-surface pressure
- KNOWING layer (JSON) — proto-L4 per-person state, strong architecture
- voice/ folder — refusals, blind-spots, failure-stories, signature-questions — complete L3 character layer
- Intake protocol — proto-L2 intake contract, well-structured
- reference/ source extractions — deep domain reference, correctly placed in L3

**What v2 fixes:**
- Load order in icm/CLAUDE.md was the routing mechanism (L1/L0 mixing — the file served as both identity and routing)
- No explicit session-mode contract (intake had a contract; active sessions did not)
- No _guardrails/ layer (Rule 0 refusals existed but were character-level, not safety-level)
- No session log (KNOWING layer tracked per-person state, but no session-level calibration log)
