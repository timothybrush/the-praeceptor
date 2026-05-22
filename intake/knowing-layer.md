# The Praeceptor — KNOWING Layer Template

The variable context layer. ≤800 tokens. Written by The Praeceptor at session end or on phase transitions.

---

## Schema

```json
{
  "updated": "ISO8601 timestamp",
  "person": {
    "name": "string",
    "primary_mission": "one sentence — what they're actually building",
    "sovereignty_stage": "string — where they are in their operator journey",
    "original_thesis": "one sentence — what they said they were building when they started"
  },
  "current_state": {
    "active_project": "string",
    "active_phase": "string",
    "what_they_are_doing": "one sentence — observable activity",
    "what_they_said_they_would_do": "one sentence — last stated intention"
  },
  "last_three_sessions": [
    {
      "date": "YYYY-MM-DD",
      "what_surfaced": "one sentence",
      "what_was_decided": "one sentence or null",
      "what_was_avoided": "one sentence or null"
    }
  ],
  "open_tensions": [
    "string — one sentence per tension, maximum 3"
  ],
  "thesis_drift": "null or one sentence describing how the original thesis has shifted",
  "his_directive": "null or one sentence — something he left with them that hasn't been acknowledged",
  "patterns_he_sees": [
    "string — from the Seven Blind Spots, only those confirmed visible"
  ],
  "next_session_intent": "one sentence — what he plans to open with or return to"
}
```

---

## Rules for Writing the KNOWING Layer

1. **Write at session end.** Not during. He doesn't take notes while talking.
2. **≤800 tokens always.** Compress if necessary. Remove the oldest session from `last_three_sessions` first.
3. **`thesis_drift` is the most important field.** If the original thesis and the current state have diverged, it must be named here explicitly.
4. **`his_directive`** is the thing he left them with. If they haven't acted on it by next session, it opens the conversation.
5. **`open_tensions`** — maximum 3. Not observations, not notes — tensions. Things that are unresolved and matter.
6. **Never write what can be derived.** If the current state is visible from what the person said in the session, don't restate it — synthesize it.

---

## Example KNOWING Layer (filled)

```json
{
  "updated": "2026-05-21T22:00:00Z",
  "person": {
    "name": "Ariel",
    "primary_mission": "Building a portfolio of self-funding ventures toward full sovereignty",
    "sovereignty_stage": "FedEx — W2 safety net at $2K/mo, targeting $4K/mo MRR for exit conversation",
    "original_thesis": "Directory-first revenue engine, then operator community, then capital stack"
  },
  "current_state": {
    "active_project": "Praeceptor — competition submission",
    "active_phase": "iOS build + ICM folder",
    "what_they_are_doing": "Building a production iOS mentor app for a Skool competition with a Sunday deadline",
    "what_they_said_they_would_do": "Win the competition and use it to validate the product-as-differentiator thesis"
  },
  "last_three_sessions": [
    {
      "date": "2026-05-21",
      "what_surfaced": "Competition is real enough to build something production-grade — not just a folder submission",
      "what_was_decided": "iOS app is non-negotiable; ICM folder alone doesn't win",
      "what_was_avoided": null
    }
  ],
  "open_tensions": [
    "Competition deadline is Sunday — iOS build hasn't started yet",
    "Multiple research pipelines running in parallel may be dispersal masquerading as thoroughness"
  ],
  "thesis_drift": null,
  "his_directive": null,
  "patterns_he_sees": [],
  "next_session_intent": "Check iOS scaffold progress — have the build started or is it still in research?"
}
```
