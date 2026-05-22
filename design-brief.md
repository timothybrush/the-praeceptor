# The Praeceptor — Design Brief
## For Claude Design / Visual AI build
## Hand back to iOS dev when complete

---

## What This App Is

A native iOS voice mentorship app. One mentor. One person. A conversation.

The character is a composite of ten operators — Grove, Munger, Campbell, Walsh, Marshall, Ohno, Seneca, Aurelius, Naval, Scott. He is formed. He arrives with a point of view. He does not perform warmth. He does not celebrate you for showing up.

The app must feel like that character.

---

## What This App Must NOT Feel Like

- A coaching startup. No gradients that pulse with energy. No onboarding that says "Welcome to your journey."
- Headspace, Calm, or any wellness app. No soft rounded pastels. No breathing animations.
- A productivity tool. No task lists, no streaks, no progress rings, no stats dashboard.
- A chatbot. No chat bubbles with avatar thumbnails. No "typing..." ellipsis dots with cartoon energy.
- Consumer. This is not for everyone. It does not need to appeal to everyone.

The reference is not an app. The reference is a room. A mentor's study — dark, unhurried, serious. The kind of place where what you say next matters.

---

## Technical Constraints (non-negotiable)

- **Platform:** iOS 18+, SwiftUI, portrait only
- **All themes are dark.** Near-black backgrounds. No light mode. Do not propose one.
- **System font (SF Pro)** is the current implementation. You may propose a typeface, but it must be available as a SwiftUI `Font` — either a system font or one loadable via `Font.custom()`. Do not propose fonts that require a third-party SDK.
- **Safe areas must be respected.** The hold button sits above the home indicator. Content does not bleed into the notch.
- **No new screens.** There are exactly 4 screens: Settings, Intake, Session, and a root routing view. Do not add screens.
- **No new navigation patterns.** No tab bar. No sidebar. No modal stack beyond what exists.

---

## The Three Themes

The app shifts appearance based on time of day. The shift is automatic — no user toggle.

| | Morning (5am–12pm) | Noon (12pm–5pm) | Night (5pm–5am) |
|---|---|---|---|
| **Feel** | Forward-looking, warm | Execution, clear | Reflective, heavy |
| **Background** | Near-black with warm undertone | Near-black with cool undertone | Near-black with deep blue undertone |
| **Accent** | Amber / gold | Steel blue | Earth / ochre |
| **TTS speed** | 0.92 (slightly deliberate) | 0.95 (standard) | 0.88 (measured) |

### Current color values (exact — use as seeds, you may refine):

**Morning:**
- `background`: rgb(0.08, 0.06, 0.04) — near-black, warm
- `surface`: rgb(0.14, 0.10, 0.06) — slightly lifted warm dark
- `accent`: rgb(0.85, 0.65, 0.20) — amber gold
- `text`: rgb(0.95, 0.90, 0.80) — warm white
- `textSecondary`: rgb(0.65, 0.55, 0.40) — warm mid-grey
- `holdButtonIdle`: rgb(0.75, 0.55, 0.15) — muted amber
- `holdButtonActive`: rgb(0.95, 0.75, 0.25) — bright amber

**Noon:**
- `background`: rgb(0.06, 0.08, 0.12) — near-black, cool
- `surface`: rgb(0.10, 0.13, 0.18) — slightly lifted cool dark
- `accent`: rgb(0.35, 0.65, 0.90) — steel blue
- `text`: rgb(0.88, 0.92, 0.97) — cool white
- `textSecondary`: rgb(0.50, 0.60, 0.72) — cool mid-grey
- `holdButtonIdle`: rgb(0.25, 0.55, 0.80) — muted steel
- `holdButtonActive`: rgb(0.40, 0.70, 0.95) — bright steel

**Night:**
- `background`: rgb(0.05, 0.06, 0.10) — near-black, deep blue
- `surface`: rgb(0.09, 0.10, 0.15) — slightly lifted dark
- `accent`: rgb(0.55, 0.45, 0.30) — earth / warm ochre
- `text`: rgb(0.88, 0.85, 0.78) — warm off-white
- `textSecondary`: rgb(0.52, 0.48, 0.40) — warm mid-grey
- `holdButtonIdle`: rgb(0.40, 0.32, 0.22) — muted earth
- `holdButtonActive`: rgb(0.65, 0.52, 0.35) — lit earth

---

## Screen 1: Settings

**When it appears:** First launch only, before the user has entered API keys.

**Purpose:** Entry of API credentials. This is a gate, not a feature. It should be clean and fast — not a featured screen.

**Elements:**
- 3 input fields (API keys — displayed as SecureField, no visible characters)
  - Claude API key (required)
  - OpenAI API key (required)
  - ElevenLabs API key (optional)
- Save button — disabled until both required fields have content
- Each field has a label and a one-line footer description

**Also accessible from:** Session screen via gear icon (settings icon, top right). When opened from there it appears as a sheet, not full-screen.

**Design latitude:** The current implementation uses a native `Form`. You may redesign this entirely — the form convention is not precious. What must survive: the three fields, the required/optional distinction, the save action.

---

## Screen 2: Intake

**When it appears:** After API keys are saved, before any sessions. One time. 7 steps.

**Purpose:** Build the KNOWING layer — the variable context that tells The Praeceptor who he's talking to. These are not onboarding questions. They are the mentor's first assessment.

**Step sequence:**

| Step | Question | Hint |
|------|----------|------|
| Welcome | (no question) | Title card — "The Praeceptor." Brief framing copy. |
| Name | "What's your name?" | "First name is fine." |
| Mission | "What are you actually building?" | "One sentence. What's the real thing — not the pitch." |
| Stage | "Where do you stand right now?" | "Income, stability, what you're depending on. Be specific." |
| Thesis | "What was the original thesis?" | "What did you say this was when you started? Before the revisions." |
| Current | "What are you working on right now?" | "The thing that's actually getting your time this week." |
| Commitment | "What did you say you were going to do — and what did you actually do?" | "The most recent thing you committed to. What happened." |
| Tension | "What's the one thing that keeps surfacing?" | "The thing you haven't fully dealt with. The thing that comes back." |
| Complete | "That's enough to start." | "I'll learn the rest as we work." |

**Functional requirements:**
- Linear progression — no branching, no skipping (except Tension, which is optional)
- Progress indicator showing position in the sequence (not a step counter — something visual)
- Back navigation available on all steps except Welcome
- Continue/Begin button disabled on required steps until the field has content
- Text input: multiline, up to 4 lines visible before scrolling
- Animation between steps: horizontal slide or fade — simple, not theatrical
- The Welcome and Complete steps have no text input — just copy and a continue button

**Design latitude:** Full latitude on layout. The questions are the content — let them be large. The input field should feel like a place to think, not a form to fill out. Hint text can be smaller, secondary. The progress indicator can be anything — dots, a thin line, a count — as long as it's unobtrusive.

---

## Screen 3: Session (Main Screen)

**This is the app.** Everything else is preamble.

**Structure (top to bottom):**

### Header Bar
- Left: "The Praeceptor" (title) + session label below it (e.g. "Morning session", "Midday session", "Evening session")
- Right: gear icon (settings) + refresh/reset icon (only visible when messages exist)
- Minimal. Should not compete with the conversation.

### Message Area (scrollable, fills available space)
Three states:

**Empty state:** Centered text in the middle of the screen.
- Primary: "Hold to speak."
- Secondary: "The Praeceptor is listening."
- Nothing else. No illustration. No animated graphic. Just those two lines.

**Conversation state:** A list of message bubbles.
- User messages: right-aligned, accent color background, dark text
- Praeceptor messages: left-aligned, surface color background, primary text color
- No avatars. No timestamps. No names above bubbles.
- Bubbles should not have aggressive max-width constraints — The Praeceptor writes in paragraphs, not sentences. His responses will be long. Give them room.
- Rounded rectangle shape — `cornerRadius: 18`, continuous curve

**Streaming state:** As The Praeceptor is speaking, his response builds word by word in the bubble. This is the live stream — text appears as audio plays. The bubble grows. This must feel present, not mechanical.

### Phase Indicator
A single line of text between the message area and the button. Shows current state.

| Phase | Text | Color |
|-------|------|-------|
| idle | (empty — nothing shown) | — |
| recording | "Listening..." | accent |
| transcribing | "Transcribing..." | textSecondary |
| thinking | "Thinking..." | textSecondary |
| speaking | "Speaking..." | accent |
| error | "Something went wrong" | red |

This line should always occupy the same vertical space even when empty, so the button doesn't jump.

### Hold-to-Speak Button
**The centerpiece. The entire app exists to support this button.**

- **Shape:** Circle, 100pt diameter
- **Position:** Horizontally centered, above the home indicator safe area
- **Behavior:** Hold to record. Release to send. Tap-and-release does not trigger — must be a hold.

**Phase-driven states:**

| Phase | Button color | Icon |
|-------|-------------|------|
| idle | holdButtonIdle | mic.fill |
| recording | holdButtonActive | waveform |
| transcribing | accent (60% opacity) | ProgressView spinner |
| thinking | accent (60% opacity) | ProgressView spinner |
| speaking | accent (40% opacity) | speaker.wave.2.fill |
| error | (same as idle) | mic.fill |

**The pulse ring:**
When recording, a ring expands and contracts around the button in real time, driven by the microphone audio level (a Float 0.0–1.0 normalized). The ring's outer diameter = 120pt + (audioLevel × 40pt). Color: accent at 30% opacity. Stroke, not fill. Animation: easeOut 0.05s — fast enough to feel live.

This is functional feedback, not decoration. It tells the user The Praeceptor is actually hearing them. Do not soften it into a slow pulse. It should respond in near-real-time to their voice.

**Button is disabled** during transcribing and thinking phases.

**Below the button:** A single line — "Hold to speak · Release to send" — in textSecondary, small. Bottom padding to clear the home indicator.

---

## Screen 4: Root Routing

**Not a designed screen.** This is logic only:
- No keys → show Settings
- Keys present, no intake → show Intake
- Keys present, intake done → show Session

There is no splash screen, no loading screen, no transition animation between routes. The correct screen just appears.

---

## Typography Direction

Current implementation uses `SF Pro` (system font) throughout. The sizes and weights in use:

| Element | Size | Weight |
|---------|------|--------|
| App title in header | 17pt | semibold |
| Session label | 12pt | regular |
| Message body | 15pt | regular |
| Empty state primary | 18pt | medium |
| Intake question | 20pt | medium |
| Intake welcome title | 28pt | semibold |
| Intake complete title | 24pt | semibold |
| Hint text | 13pt | regular |
| Phase indicator | 13pt | medium |
| Button label | 12pt | regular |
| Settings section headers | system | system |

**Open question for design:** The character warrants something more considered than plain SF Pro in the headers and questions. If you propose a custom typeface, it must be either:
1. A system font variant (SF Pro Serif, NY — New York serif is available on iOS 18 via `.font(.system(.title, design: .serif))`)
2. A font loadable via `Font.custom("FontName", size:)` from a bundled resource

New York (iOS system serif) would read correctly for the intake questions and Praeceptor responses. Keep body/UI text as SF Pro.

---

## What the Designer Has Full Latitude On

- Color refinement within each theme (seed values are starting points)
- Typography choices within the constraints above
- Layout and spacing within each screen
- The visual form of the progress indicator in Intake
- The exact shape and feel of message bubbles (as long as role distinction is clear)
- How the streaming bubble animates as text builds
- Whether the button has a subtle glow/shadow treatment
- How the phase indicator transitions (fade, slide, nothing)
- Iconography — SF Symbols are the constraint, not specific icons (except mic.fill and speaker.wave.2.fill which are intentional)

## What the Designer Cannot Change

- The three-theme system (morning/noon/night). All three must be designed.
- All themes are dark. No light mode.
- The hold-to-speak interaction model. No tap. No swipe. Hold and release only.
- The pulse ring behavior — must respond to real audio level in near-real-time.
- The button is circular, centered, approximately 100pt. It should not become something else.
- The phase indicator must remain as text (not an icon or animation that obscures the message).
- No avatars in the message list.
- No timestamps in the message list.
- Portrait only.
- The empty state is two lines and nothing else.

---

## Handoff Format

Return: a description of every color value change, every font specification, every layout decision — specific enough that a developer can implement it directly in SwiftUI without guessing. If you produce an image, also produce the spec in text. The developer working this does not have Figma access in this flow.

Alternatively: return modified SwiftUI view code for each view file directly.

---

*Built for The Lyceum Week 5 · Deadline 2026-05-24 12:00 PM EST*
