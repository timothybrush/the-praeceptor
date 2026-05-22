# The Praeceptor — Design Brief v2
## For Design AI — structural and functional brief only
## Aesthetic direction will be provided separately by the client
## Hand final spec back to iOS developer for implementation

---

## North Star

The app must feel like its character. Not a product. Not a service. A relationship.

Every screen, every state, every transition is in service of one experience: the user is in the presence of someone who has seen more than they have and is choosing to give them their time.

If the design feels like an app — startup-polished, onboarding-optimized, engagement-maximized — it has failed. If it feels like a room you don't want to leave, it has succeeded.

---

## The Character

The Praeceptor is a composite of ten operators: Andy Grove, Charlie Munger, Bill Campbell, Bill Walsh, George Marshall, Taiichi Ohno, Seneca, Marcus Aurelius, Naval Ravikant, Kim Scott.

He is not a coach. He is a mentor. The distinction matters to the design: a coach is a service you pay for. A mentor chooses you. He arrived with a point of view before the user said a word.

**His voice is:**
- Direct. No wasted words. Short sentences for diagnosis. Oblique when the lesson needs to arrive sideways.
- Warm when it's earned. Not performed warmth — present warmth. The difference is legible.
- Socratic. He leads to the answer. He does not give it.
- Firm. The firmness is earned, not performed. He commands respect without asking for it.
- Patient. He does not fill silence. Silence is where the real answer arrives.

**He does not:**
- Celebrate the user for showing up.
- Validate performance that doesn't meet standard.
- Lower the bar because circumstances are hard.
- Use corporate language, jargon, or management frameworks.
- Perform empathy as a substitute for honesty.

**The test for any design decision:** Does this look like the place where that person would speak? If it looks like a wellness app, a productivity tool, or a coaching startup, the answer is no.

---

## How the App Works — Functional Overview

The user has a voice conversation with The Praeceptor. That is the entire app.

**Primary input mode — voice:**
1. User holds the mic button
2. Device records audio
3. Release sends it
4. Audio is transcribed (Whisper API)
5. The Praeceptor generates a response (Claude API, streaming)
6. Response is spoken aloud (OpenAI TTS, "onyx" voice)
7. While the response streams in, the text builds word by word in the conversation

**Secondary input mode — text:**
- A keyboard icon is available to switch to text input
- Text input is a fallback — voice is the intended mode
- Same pipeline: text → Claude → TTS → spoken response
- Text mode is not hidden, but it is secondary. The hierarchy must be legible.
- If microphone permission is denied by the user, text input appears automatically.

**Conversation persistence:**
- Messages survive app restarts
- The session continues where it left off

**Pipeline phases — the app signals its state at all times:**

| Phase | What's happening |
|-------|-----------------|
| idle | Nothing. Waiting. |
| recording | Microphone is live. The Praeceptor is hearing you. |
| transcribing | Audio is being converted to text. |
| thinking | Claude is generating a response. |
| speaking | TTS is playing. The Praeceptor is speaking. |
| error | Something failed. One-line message. |

The user must always know which phase they're in. The phase is shown as text above the mic button.

---

## Themes — Time of Day

The app has three automatic themes based on time of day. No user toggle. No light mode. The shift is silent and automatic.

| Theme | Hours | Character of the time |
|-------|-------|----------------------|
| Morning | 5:00 AM – 11:59 AM | Forward-looking. What does today hold. |
| Midday | 12:00 PM – 4:59 PM | Execution. What is moving right now. |
| Evening | 5:00 PM – 4:59 AM | Reflective. What happened. What was learned. |

Each theme has its own complete color system. The designer will specify three full palettes — one per theme. Each palette includes: background, surface (cards/bubbles), accent (primary brand color for the theme), text primary, text secondary, mic button idle state, mic button active state.

All three themes are dark. There is no light mode. Do not propose one.

---

## Screen 1 — Settings

**When it appears:** First launch if no API keys are saved. Also accessible as a sheet from the Session screen via a gear icon.

**Purpose:** Enter API credentials. This is a gate. It should be fast, clear, and forgettable — not a designed destination.

**Functional elements (all required):**
- API Key field: Claude (Anthropic) — required. Label + secure text input + one-line description footer.
- API Key field: OpenAI — required. Label + secure text input + one-line description footer.
- API Key field: ElevenLabs — optional. Label + secure text input + one-line description footer. Must be visually distinct as optional.
- Save button: disabled until both required fields have content. Enabled once both are non-empty.
- Session Reminders section: three independent toggles — Morning (8:00 AM), Midday (12:00 PM), Evening (6:00 PM). Each toggle has a label and a time subtitle. Character-voiced footer beneath the section.
- When accessed as a sheet: Cancel button to dismiss without saving.

**What the designer controls:** Full layout. The native iOS Form is not required. Any layout that presents all elements clearly is acceptable.

**What cannot change:** All six functional elements above must be present. The required/optional distinction must be legible. The save action must be visually tied to the two required fields.

---

## Screen 2 — Intake

**When it appears:** After API keys are saved, before any sessions. One time only. 7 steps plus a welcome and a completion card.

**Purpose:** The Praeceptor's first assessment. These are not onboarding questions. They are the mentor learning who he's talking to before he begins.

**Step sequence:**

| Step | Type | Prompt | Hint |
|------|------|--------|------|
| 0 | Welcome card | "The Praeceptor." | Fixed copy: "Before we begin, I need to know who I'm talking to. Not your background. Not your credentials. Who you are, what you're building, and where you actually stand." No input. Continue button. |
| 1 | Text input | "What's your name?" | "First name is fine." |
| 2 | Text input | "What are you actually building?" | "One sentence. What's the real thing — not the pitch." |
| 3 | Text input | "Where do you stand right now?" | "Income, stability, what you're depending on. Be specific." |
| 4 | Text input | "What was the original thesis?" | "What did you say this was when you started? Before the revisions." |
| 5 | Text input | "What are you working on right now?" | "The thing that's actually getting your time this week." |
| 6 | Text input | "What did you say you were going to do — and what did you actually do?" | "The most recent thing you committed to. What happened." |
| 7 | Text input (optional) | "What's the one thing that keeps surfacing?" | "The thing you haven't fully dealt with. The thing that comes back." |
| 8 | Completion card | "That's enough to start." | Fixed copy: "I'll learn the rest as we work." No input. Begin button. |

**Functional requirements:**
- Linear progression. No branching. No skipping required steps.
- Step 7 (Tension) is optional — the Continue button is enabled without input.
- All other text input steps: Continue button disabled until the field has content.
- Back navigation on all steps except Welcome.
- Progress indicator showing position in sequence. Unobtrusive. Visual.
- Text input: multiline. Up to 4 lines visible before scrolling internally.
- Transition between steps: horizontal slide (forward = left, back = right) or simple fade.

**What the designer controls:** Full layout per step. The question should be visually dominant. The hint secondary. The input field below both. Progress indicator position and form.

**What cannot change:** The question text and hint text are fixed. The step sequence is fixed. The optional/required logic is fixed.

---

## Screen 3 — Session

**This is the app.** Every other screen is preamble.

### 3a — Header Bar

Always visible at top.

**Left side:**
- "The Praeceptor" — primary label, semibold
- Session label below it — secondary text, smaller: "Morning session" / "Midday session" / "Evening session" (changes with theme)

**Right side:**
- Gear icon → opens Settings as a sheet
- Reset/refresh icon → appears only when conversation has messages. Tapping clears the conversation (with confirmation or destructive action).

The header should not compete with the conversation below it.

### 3b — Message Area

Fills all available space between header and controls. Scrollable.

**Empty state (no messages):**
Two lines, vertically centered in the available space:
- Primary: "Hold to speak."
- Secondary: "The Praeceptor is listening."
Nothing else. No illustration. No decoration. Just those two lines.

When text input mode is active and empty state is showing, the secondary line may read: "Type below or hold to speak."

**Conversation state:**
- User messages: right-aligned. Accent color background. Dark text (legible against accent).
- Praeceptor messages: left-aligned. Surface color background. Primary text color.
- No avatars. No timestamps. No sender names above bubbles.
- Bubble shape: rounded rectangle, continuous curve, 18pt corner radius.
- Bubble width: no aggressive max-width constraint. The Praeceptor writes in paragraphs. His responses can be long. Give them room — full width minus horizontal padding is acceptable.
- Vertical spacing between bubbles: 16pt.

**Streaming state:**
As the Praeceptor's response generates, the text builds word by word in a left-aligned bubble. The bubble grows with the content. This is a live stream — it must feel present, not mechanical.

### 3c — Phase Indicator

A single line of text between the message area and the mic button. Always occupies the same vertical space so the button does not jump when the phase changes.

| Phase | Text shown | Color |
|-------|-----------|-------|
| idle | (nothing — empty) | — |
| recording | "Listening..." | accent color |
| transcribing | "Transcribing..." | text secondary |
| thinking | "Thinking..." | text secondary |
| speaking | "Speaking..." | accent color |
| error | "Something went wrong" | red / error color |

### 3d — Mic Button (Hold-to-Speak)

**The centerpiece. The entire app exists around this button.**

- Shape: circle
- Diameter: approximately 100pt
- Position: horizontally centered, fixed above home indicator safe area

**States by phase:**

| Phase | Button appearance | Icon |
|-------|-----------------|------|
| idle | accent color, standard opacity | mic.fill |
| recording | accent color, bright / active | waveform |
| transcribing | accent color, reduced opacity | loading spinner |
| thinking | accent color, reduced opacity | loading spinner |
| speaking | accent color, low opacity | speaker.wave.2.fill |
| error | returns to idle appearance | mic.fill |

**Interaction:** Hold to record. Release to send. A brief tap without a hold does not trigger recording — the gesture requires sustained pressure.

**Pulse ring (recording phase only):**
When recording is active, a ring appears around the button. Its outer diameter is driven in real time by the microphone audio level (Float 0.0–1.0). The ring expands and contracts as the user speaks — it is live audio visualization, not a looping animation. It must respond within ~50ms to audio changes.

- Outer diameter range: base diameter + 20pt (silence) to base diameter + 60pt (loud)
- Style: stroke only (not filled)
- Color: accent at ~30% opacity
- Animation easing: fast easeOut — must feel live, not smoothed into a slow pulse

**Button disabled during:** transcribing and thinking phases.

### 3e — Input Mode Footer

Below the mic button, above the home indicator safe area.

**Voice mode (default):**
- Text: "Hold to speak · Release to send"
- A small keyboard icon to the right of or below that text
- Tapping the keyboard icon reveals text input mode (animated transition)

**Text mode:**
- Text field: multiline, 1–4 lines, accent tint cursor
- Send button: appears when field has content and app is idle. Tapping sends the message through the same pipeline as voice (Claude → TTS → spoken response)
- Mic icon: tapping returns to voice mode, clears the text field
- Placeholder text in the field: "Type a message..."
- Background of the text field: surface color

The hierarchy is deliberate: voice is the mode. Text is the fallback. The design should make that clear without hiding text input.

---

## Surface 4 — Home Screen Widget

Two sizes: small and medium. Both tap to open the app and auto-start a recording session.

**Small widget:**
- App name: "The Praeceptor"
- Session label below it (updates hourly): "Morning session" / "Midday session" / "Evening session"
- Mic icon, centered
- "Tap to speak" below icon

**Medium widget:**
- Left column (~80pt): mic icon, centered vertically. "Tap to speak" below.
- Right column: app name (larger, semibold). Session label. A two-line copy block: "Hold to speak. / The Praeceptor is ready."

Both widgets always use the same background. No time-of-day adaptation in the widget — one consistent visual.

---

## Surface 5 — Dynamic Island / Live Activity

Active during any pipeline phase when the user has left the app.

**Compact state (pill):**
- Leading: phase icon (changes with phase)
- Trailing: phase label ("Listening" / "Thinking" / "Speaking")
- A visible accent-colored ring around the entire Dynamic Island pill

**Minimal state (one ear of the pill when competing with another activity):**
- Phase icon only

**Expanded state (long press):**
- Leading: phase icon, large
- Center: "The Praeceptor"
- Trailing: session label ("Morning session" etc.)
- Bottom: phase description
  - Recording: "Listening..."
  - Transcribing: "Processing what you said..."
  - Thinking: "The Praeceptor is thinking."
  - Speaking: "Speaking. Come back when it stops."

**Lock screen banner:**
- Full-width. App background color fills the banner.
- Left: phase icon, large, in a breathing frame
- Center: "The Praeceptor" + phase description
- Right: session label

---

## Required Outputs for Implementation

The developer implementing this in SwiftUI needs specific values, not general direction. The handoff must include:

**1. Color system — all three themes, all tokens**

For each theme (Morning / Midday / Evening), provide:
- `background` — hex or RGB
- `surface` — hex or RGB (card and bubble backgrounds)
- `accent` — hex or RGB (primary brand color for that time of day)
- `text` — hex or RGB (primary text)
- `textSecondary` — hex or RGB (hints, labels, subtitles)
- `holdButtonIdle` — hex or RGB (mic button default state)
- `holdButtonActive` — hex or RGB (mic button while recording)

**2. Typography — all roles**

For each text role, provide:
- Font name (must be a SwiftUI-available font: system font, SF Pro variant, New York serif via `.font(.system(.size, design: .serif))`, or a bundled custom font loadable via `Font.custom("Name", size:)`)
- Size in points
- Weight (ultraLight / thin / light / regular / medium / semibold / bold / heavy / black)

Roles needed:
- App title in header ("The Praeceptor")
- Session label ("Morning session")
- Message body text (both user and Praeceptor bubbles)
- Empty state primary ("Hold to speak.")
- Empty state secondary ("The Praeceptor is listening.")
- Intake question text
- Intake welcome title
- Intake hint text
- Phase indicator text
- Voice footer label ("Hold to speak · Release to send")
- Settings field labels
- Settings footer text

**3. Spacing and layout**

For each screen, provide:
- Horizontal padding (content inset from screen edges)
- Vertical spacing between major sections
- Bubble corner radius (if different from current 18pt)
- Bubble horizontal padding (text inset inside bubble)
- Bubble vertical padding (text inset inside bubble)
- Mic button diameter
- Mic button pulse ring base offset and max offset

**4. Shape and border treatments**

For any element with a border, glow, shadow, or non-standard shape:
- Border width and color
- Shadow radius, offset, and color
- Glow spread and color (if applicable to the mic button or other elements)

**5. Animation specs**

For any animated element:
- Duration in seconds
- Easing curve
- Trigger condition

Minimum required: phase indicator transition, text input show/hide, step transitions in Intake, mic button state changes.

**6. Icon choices**

If proposing SF Symbol alternatives to current icons:
- Symbol name (exact SF Symbols name)
- Size
- Weight

Current icons in use:
- Mic button idle: `mic.fill`
- Mic button recording: `waveform`
- Mic button speaking: `speaker.wave.2.fill`
- Settings: `gearshape`
- Reset: `arrow.clockwise`
- Text mode toggle: `keyboard`
- Send button: `arrow.up.circle.fill`
- Return to voice: `mic.fill`

**7. Intake progress indicator**

Provide the exact visual form of the progress indicator: dots / line segments / count text / other. Include: dimensions, colors (filled vs unfilled), spacing, position on screen.

---

## What the Designer Has Full Latitude On

- All color decisions within the three-theme structure
- Typography — font family, size, weight for every role
- Layout and spacing within each screen
- The exact visual form of message bubbles (as long as role distinction is clear)
- The progress indicator form in Intake
- Whether the mic button has glow, shadow, or ring treatments
- How phase indicator transitions (fade, slide)
- How text input mode animates in and out
- Iconography within SF Symbols

## What Cannot Change

- Three automatic themes (morning/noon/night) — all three must be fully designed
- No light mode
- Hold-to-speak interaction model — no tap, no swipe, hold and release only
- Pulse ring must respond to real audio level in real time — not a decorative loop
- Mic button is circular and centered
- Phase indicator is text
- No avatars or timestamps in the message list
- Portrait only
- Empty state is two lines, nothing else
- Text input is secondary to voice — hierarchy must be legible in the design

---

## Handoff Format Required

Return everything the developer needs to implement directly in SwiftUI:

1. **Color token table** — all three themes × all tokens, in hex or RGB
2. **Typography spec** — all roles, font name + size + weight
3. **Spacing spec** — all screens, padding + spacing values in points
4. **Animation spec** — duration + easing for every animated element
5. **Component notes** — any non-obvious behavior or visual treatment

Optionally: SwiftUI view code for any component. If code is provided, it must compile against SwiftUI and iOS 18. It will be integrated directly.

The developer does not have Figma access in this flow. All specs must be in text or code.

---

*Built for The Lyceum Week 5 · Deadline 2026-05-24 12:00 PM EST*
*v2 — structural/functional only. Aesthetic direction provided separately by client.*
