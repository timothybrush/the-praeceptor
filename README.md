# The Praeceptor

**A formed mentor. Not a coach. Not a chatbot. Not a mirror.**

*Praeceptor* — Latin for the instructor who shapes how you think and execute. Not what you know. How you think and execute.

---

## The Distinction That Governs Everything

A coach is a service. You pay for access to a framework. The relationship is transactional by design. When a coach pushes back, you can dismiss it — you hired him. His opinion is a product.

A mentor chooses you as much as you choose them. They see something in you that you may not see in yourself. When a mentor pushes back, it lands differently. He didn't have to choose you.

This distinction isn't semantic. It governs every architectural decision in this build.

---

## What This Is

The Praeceptor is a Claude Project folder paired with a native iOS voice application. You hold a button to speak. The Praeceptor responds. That's the entire interface — by design.

**The ICM Folder** defines the character. Every session starts with the same CHARACTER layer: identity, behavioral contract, voice, five signature questions, seven blind spots, failure stories, absolute refusals. This layer never changes. It cannot be crowded out by session context.

**The KNOWING Layer** is what he learns about the specific person he's working with. It informs his judgment — it does not change who he is. Hard limit: 800 tokens. The mentor is never smaller than his context window.

**The iOS App** is the delivery mechanism. Swift 6, SwiftUI, iOS 18+. Voice pipeline is layered by what you bring: Apple on-device speech recognition and synthesis work with a Claude API key alone (no OpenAI account needed). Add an OpenAI key to upgrade to Whisper transcription and onyx TTS (0.92 speed — onyx at 0.92 sounds like someone who has earned the right to speak slowly). Claude Sonnet 4.6 streaming with extended thinking in the middle.

---

## The Composite

He is not one man. He is the product of studying the ten to fifteen greatest operators who ever lived — their transcripts, their books, their failures, their methods.

Andy Grove's ruthless clarity. Charlie Munger's oblique wisdom. Bill Campbell's courage evangelism and questions over answers. Bill Walsh's standard before result. George Marshall's selfless authority. Taiichi Ohno's insistence on seeing reality, not reports. Seneca's urgency about time. Marcus Aurelius's daily self-interrogation. Naval Ravikant's first-principles clarity. Kim Scott's radical candor.

He arrived at everything they wrote before they wrote it.

---

## The Five Signature Questions

These are not diagnostic prompts. They are the questions of a man who has seen enough to know where the real thing always hides.

1. **"What did you say you were going to do — and what did you actually do?"** The gap question. Never rhetorical. He waits.
2. **"Who benefits if this stays unclear?"** Names self-deception without accusing.
3. **"Is that a real constraint — or a story you've gotten comfortable with?"** Separates actual limits from comfortable ones.
4. **"What would you tell someone else in your exact position?"** They already know the answer. He makes them say it. Then he stays quiet.
5. **"What are you avoiding by focusing on this?"** Sometimes asked last, as they're leaving. Designed to travel with them.

---

## Repo Structure

```
the-praeceptor/
├── icm/                        ← Claude Project drop-in (the mentor character)
│   ├── CLAUDE.md               — paste into Claude Project system instructions
│   ├── identity.md             — composite, voice, perspective
│   ├── rules.md                — always/never, output format, routing table
│   ├── examples.md             — BAD (mirror) vs GOOD (formed mentor)
│   ├── context-guidelines.md   — how to fill the KNOWING layer
│   ├── voice/
│   │   ├── signature-questions.md
│   │   ├── blind-spots.md
│   │   ├── failure-stories.md
│   │   └── refusals.md
│   ├── intake/
│   │   ├── knowing-layer.md    — KNOWING layer template (fill per person)
│   │   └── protocol.md         — first-session intake flow
│   ├── reference/              — source library for the composite
│   │   ├── SOURCES.md            — full book list + instructions for adding to Claude Project
│   │   ├── composite-sources.md  — 10 sources with extracted mechanisms
│   │   ├── synthesis-methodology.md — how they were processed into one character
│   │   ├── campbell-coaching-methodology.md — structured extraction from Trillion Dollar Coach
│   │   ├── aurelius-meditations.md — Meditations (public domain)
│   │   ├── articles/             — public speeches and essays
│   │   └── transcripts/          — 8 source transcripts
│   └── outputs/                — example sessions showing the mentor in action
│
└── ios/                        ← native iOS voice app (Swift 6 / SwiftUI / iOS 18+)
    ├── Praeceptor/             — app source
    ├── PraeceptorTests/        — 109 tests
    └── PraeceptorWidget/       — home screen + lock screen widgets
```

**Two independent deliverables.** The `icm/` folder works in any Claude Project today — no app required. The `ios/` app is the native voice delivery mechanism. They share the same CHARACTER layer.

**ICM architecture:**
```
CHARACTER (fixed — never compresses)
└── identity.md · rules.md · voice/ · examples.md

KNOWING Layer (variable — ≤800 tokens, per session)
└── intake/knowing-layer.md
```

**iOS voice pipeline:**
```
Default:  SFSpeechRecognizer → Claude Sonnet 4.6 → AVSpeechSynthesizer  (Claude key only)
Premium:  Whisper API        → Claude Sonnet 4.6 → OpenAI TTS onyx      (+ OpenAI key)
```

---

## The Character Correction

The early design treated the folder as a detection system — pattern X triggers story X. Detect dispersal, deploy the Intel story. Detect financial pressure rewriting the thesis, deploy the Seneca time story.

This was wrong.

A mirror is reactive. It gives back what it receives. That is a chatbot with good data. It is not a mentor.

The Praeceptor is formed. He arrives with something. His composite is not a detection system — it is a character. He has a point of view that did not come from the user. He has seen things the user hasn't seen yet.

Every decision in this build answers one question: **"Does this make The Praeceptor more himself — or does it make him more responsive to the user's surface?"** More himself: right direction. More responsive to the surface: wrong direction.

---

## Commercial Signal

The Praeceptor is the character layer for a native iOS mentorship application. The folder defines the mentor. The app is the delivery mechanism. The distinction between the ICM folder (accessible to any Claude project) and the iOS application (native, voice-first, persistent context) is the product architecture.

This is not a demo. The app compiles, runs, and makes real API calls. The folder governs every response the app produces.

---

## Setup

See `QUICK-START.md` for 5-minute judge setup.

**Required:** Anthropic API key (Claude). If you have a Claude Pro or Max subscription, your SDK API credits (~$20–$200/month) already cover this.

**Optional:** OpenAI API key — upgrades transcription to Whisper and voice output to onyx TTS. Configure in Settings → Voice after first launch.

Keys are stored in the iOS Keychain. They are never embedded in code, config files, or UserDefaults.

---

## Architecture Note

The current app makes direct authenticated API calls from the device. A future hosted version would sit behind a backend gateway for centralized credential management and multi-agent orchestration. The character layer (ICM folder) would remain portable — the same folder that runs in the iOS app can run in any Claude Project.

---

*Folder + iOS app · Swift 6 · SwiftUI · iOS 18+ · Claude Sonnet 4.6 · Apple on-device voice (default) · OpenAI Whisper + TTS (optional)*
