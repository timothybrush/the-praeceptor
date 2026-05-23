# Quick Start — 5 Minutes to Running

## What You Need

- Xcode 16+ (iOS 18 SDK)
- iOS 18+ simulator (iPhone 15 Pro or later recommended)
- Anthropic API key — required ([console.anthropic.com](https://console.anthropic.com))
- ElevenLabs API key — optional, for premium voice ([elevenlabs.io](https://elevenlabs.io))
- OpenAI API key — optional, for Whisper transcription + OpenAI voice

---

## Steps

**1. Open the project**
```
ios/Praeceptor.xcodeproj
```
Double-click to open in Xcode.

**2. Select the simulator target**
In the toolbar: `Praeceptor › iPhone 16 Pro` (or any iOS 18+ simulator)

**3. Build and run**
`⌘R` — first build takes ~30 seconds.

**4. Enter your Claude API key**
On first launch, the app shows a Settings screen.
- Paste your Anthropic API key → Claude field
- ElevenLabs and OpenAI keys are optional — leave blank to use Apple's on-device voice and transcription (no extra keys needed)
- Tap **Save**

Keys are stored in the iOS Keychain — you enter them once.

**5. Complete intake**
The app walks you through 7 questions to build the KNOWING layer. Answer honestly — The Praeceptor uses this context in every session.

**6. Start a session**
Hold the center button to speak. Release to send. The Praeceptor responds in voice.

---

## Testing the ICM Folder (Claude Project)

To test the character directly in Claude without the iOS app:
1. Create a new Claude Project
2. Upload all files from the `praeceptor/` folder root (`CLAUDE.md`, `identity.md`, `rules.md`, `examples.md`, `patterns-pending.md`)
3. Upload the `voice/` folder files
4. Upload the `intake/` folder files
5. In Project Instructions, paste the contents of `CLAUDE.md`
6. Start a conversation — The Praeceptor activates

---

## Architecture Notes for Reviewers

| Layer | File | Purpose |
|-------|------|---------|
| System entry | `CLAUDE.md` | Read order, two-layer architecture, Rule 0 |
| Character | `identity.md` | The composite — eight figures, voice, blind spots |
| Behavioral contract | `rules.md` | Always/never, output format by situation, routing |
| Voice patterns | `voice/*.md` | Five questions, seven blind spots, failure stories, refusals |
| Context | `intake/knowing-layer.md` | Variable layer schema, ≤800 tokens |
| Examples | `examples.md` | BAD (reactive mirror) vs GOOD (formed mentor) |
| iOS app | `ios/Praeceptor.xcodeproj` | Swift 6, SwiftUI, iOS 18+ |

---

## If the Build Fails

Common fix: check that your Xcode Command Line Tools are current.
```bash
xcode-select --install
```

For API errors during use: verify your keys in Settings (gear icon, top right).

---

*The Praeceptor · Week 5 · May 2026*
