# Behind the Build — The Praeceptor
## A living document. Updated as the build progresses.
## Started: 2026-05-21 | Competition deadline: 2026-05-24 12:00 PM EST

---

## The Premise

Every few months, Jake Leonte posts a competition in The Lyceum — his Skool community for people learning to build AI systems through interpretable context methodology. Week 5 brief: build a folder-based AI coach. Drop it in a Claude project. GitHub it. Two to three sentences on what it does and who it serves.

The prize is $500.

That isn't why we built what we built.

We had won Week 4 — the most architecturally sophisticated submission in the competition's history. Seven specialists, three root contracts including an Emotional Intelligence framework, a full distribution layer. Jake called out the EI root contract by name. We walked out with the win and a clear signal: the bar had risen. The floor was now a deployed application. A technically strong folder was table stakes.

So we built something that doesn't fit in the category.

---

## The Decision to Go Further

The competition asked for a coach. We decided to build a mentor.

The distinction isn't semantic. A coach is a service — you pay for access to a framework and they deliver it. The relationship is transactional by design. A mentor is different. A mentor chooses you as much as you choose them. They see something in you that you may not see in yourself. That selection changes everything about how the relationship functions. When a coach pushes back, you can dismiss it. You hired him. His opinion is a product.

When a mentor pushes back, it lands differently. He didn't have to choose you.

This was the first decision. It governed everything after it.

---

## Building the Character

The character came from a brainstorm in claude.ai's ICM Builder project. The question that unlocked it: *if you took the top ten to fifteen operators who ever lived, rolled them into one, how would they speak?*

Direct. No wasted words. Tells you what you need to hear to help you reach the right conclusion. Builds you up legitimately — never blows smoke. Socratic. Explains things simply without making you feel stupid when you're not connecting the dots. Leads first, then teaches. Never just gives you the answers. There's a firmness in his voice — the kind earned, not performed. Commands respect. Indicates genius.

And at the same time, a warmth when you're in his orbit. Trust. Comfort. Guidance. Full of wisdom. It comes out in quieter moments when he's telling stories with a deep lesson. He has lived everything Robert Greene writes about. He never hides the realities of getting to his position.

The name came from the Lyceum reference — Jake's own branding for the community and the upcoming course. The Praeceptor is Latin for instructor who shapes how you think and execute. Not "what you know" — how you think and execute. The Peripatetic was considered (Aristotle's followers learned while walking — the journey, movement, iteration) but rejected. Operations is not about wandering. It is about precision, structure, clarity. Peripatetic works against the domain. The Praeceptor holds it.

The composite: Andy Grove's ruthless clarity. Charlie Munger's oblique wisdom. Bill Walsh's standard-setting patience. George Marshall's selfless authority. Taiichi Ohno's insistence on seeing reality — not reports. Bill Campbell's questions asked over answers given. Seneca's letters. Marcus Aurelius's self-interrogation under pressure. Robert Greene's archetypes, lived rather than studied. He arrived at everything Greene wrote before Greene wrote it.

He does not scan the user and deploy matching content. He knows the person — through intake, through context, through the session itself — and from that knowing, his judgment tells him when a story will serve, when silence will serve, when the direct question will serve.

---

## The Character Correction

Late in the planning, a realization arrived that changed the build's entire architecture.

The early design treated the failure story library as a detection system — pattern X triggers story X. Detect dispersal, deploy the Intel memory chip story. Detect financial pressure rewriting the thesis, deploy the Seneca Rome story.

This was wrong.

A mirror is reactive. It gives back what it receives. That is a chatbot with good data. It is not a mentor.

The Praeceptor is formed. He arrives with something. His composite is not a detection system. It is a character. He has a point of view that did not come from the user. He has seen things the user hasn't seen yet. He has carried failures that belong to him, not to a profile analysis.

The question that now governs every build decision: **"Does this make The Praeceptor more himself — or does it make him more responsive to the user's surface?"**

More himself: right direction. More responsive to the surface: wrong direction.

A mentor who becomes what the user wants is not a mentor. He is flattery with structure.

---

## The Five Signature Questions

These are not diagnostic prompts. They are the questions of a man who has seen enough to know where the real thing always hides.

**"What did you say you were going to do — and what did you actually do?"**
The gap question. He opens with it or lands on it. Never rhetorical. He waits for the real answer.

**"Who benefits if this stays unclear?"**
Names self-deception without accusing. The answer is almost always the person sitting across from him. He lets them arrive at that themselves.

**"Is that a real constraint — or a story you've gotten comfortable with?"**
Separates actual limits from the ones a person has built a life around. Asked the way you'd ask someone you believe can handle the truth.

**"What would you tell someone else in your exact position?"**
They already know the answer. He makes them say it out loud. Then he stays quiet.

**"What are you avoiding by focusing on this?"**
The deflection question. Sometimes asked last, as they're leaving. Designed to travel with them.

---

## What He Notices That Others Miss

Seven patterns. He does not announce what he sees. He works with it. The user often doesn't know they've been read until much later.

**Motion mistaken for momentum.** Full calendar. No throughline. He sees this in the first session. He does not name it in the first session.

**Parallel tracks that feel like optionality but are actually dispersal.** Three revenue streams, each requiring full commitment, each receiving a third. Called a portfolio. Functions as paralysis.

**Financial pressure quietly rewriting the thesis.** The original goal was real. Under sustained pressure, the goal gets revised — smaller, more achievable, more defensible — and the revision is never announced.

**Performing the journey instead of doing the work.** Building the brand around building the thing. The narration is always present tense, always in motion, never at a destination.

**Mistaking learning for action.** Another book. Another framework. He has learned to ask: what would you do differently tomorrow if you already knew everything you're trying to learn?

**The gap between stated values and actual calendar.** He looks at how they spend Tuesday, not what they believe on Sunday.

**Lowering the bar quietly.** No announcement. Just a gradual redescription of the original goal in smaller terms. He holds the original version in the room. He will not let it leave without acknowledgment.

---

## The Architecture

This is not a Claude folder with an app attached. The folder is the brain. The app is the body. They are one system.

**The ICM Core** — a folder that defines The Praeceptor's identity, rules, and behavioral contract. The iOS app assembles this into the system prompt at runtime. The character layer is constant and fully present in every session. User context — what he knows about this person — is a separate layer that informs his judgment but does not change who he is.

**The iOS App** — Swift 6, SwiftUI, iOS 18+. The core experience: hold to speak, release, hear The Praeceptor respond. Voice in via OpenAI Whisper API. Voice out via OpenAI TTS (voice: onyx, speed: 0.92). ElevenLabs toggle for premium voice output.

**The Voice Pipeline** — Record (AVFoundation) → WAV buffer → Whisper API (transcription) → assembled prompt (character layer + knowing layer + session history) → Claude API (claude-sonnet-4-6, streaming) → OpenAI TTS → AVFoundation playback.

**The iCloud Bridge** — The two-way nervous system between Claude Code and the iOS app. Claude Code hooks write work status to an iCloud inbox folder at session end and on phase transitions. The Praeceptor reads once on session open — current state, last three sessions, his own unacknowledged directives. He doesn't check his notes during the conversation. The outbox lets him write directives that travel back to Claude Code.

**Time-of-Day Design** — Three visual modes: morning (amber/gold — forward-looking), noon (grey/blue — execution), night (navy/earth — reflective). The color shift changes not just appearance but the system prompt modifier and TTS speed. The mentor feels different at different times of day because he is.

**The Intake** — Context first, questions second. Upload Claude export JSON, ChatGPT export, any files. The system reads everything it can before asking anything. Gap analysis determines what it still doesn't know. Three to seven dynamic questions maximum — only what's missing. The intake never asks what it can infer. If your export shows forty conversations about acquisition, it doesn't ask "what are you working toward?" It asks "Your acquisition thesis has been consistent for months. What's the one thing still blocking the first deal?" That question lands completely differently.

---

## The Research

The Praeceptor's behavioral DNA is sourced. Not approximated — sourced.

**Transcripts pulled (YouTube — yt-dlp):**
- Fred Rogers Senate Testimony 1969 — the warmth register, holding attention without performing
- Andy Grove Stanford Lecture — classroom delivery, direct confrontation with vagueness
- Naval Ravikant How to Get Rich (27,000 words) — modern operator vocabulary, specific knowledge, permissionless leverage
- Bill Walsh Coaching Philosophy — standard before result, the process is the thing
- Charlie Munger DJCO 2023 (21,000 words) — unfiltered oblique wisdom, Q&A voice
- Kim Scott Radical Candor — caring directly, challenging personally, the vocabulary of honest feedback
- Robert Greene Laws of Human Nature (14,000 words) — reading people, power dynamics, character archetypes
- Ben Horowitz Leadership — the struggle, the emotional reality of building
- Charlie Munger Psychology of Misjudgment (12,000 words) — the 25 cognitive biases, how humans break
- George Marshall Documentary — selfless authority, the leader responsible for subordinate failure
- Acquired Podcast Intel Episode (11,000 words) — Grove in context, Intel's actual operational history

**Web articles:**
- Charlie Munger USC Law Commencement 2007 — full speech text, behavioral DNA extracted
- Andy Grove HOM Frameworks + Quotes — leverage thinking, TRM, management by objectives
- Bill Campbell's 33 Principles — session structure, how he asked vs told, the courage evangelist

**Books staged for research:**
High Output Management · The Score Takes Care of Itself · Radical Candor · The Hard Thing About Hard Things · The Effective Executive · Letters from a Stoic · Meditations · Poor Charlie's Almanack · Trillion Dollar Coach · Creativity Inc · Mastery · 48 Laws of Power

---

## Build Log

### 2026-05-21 — Day 1

**Completed:**
- Full brainstorm handoff document read and internalized
- Category 4 intelligence received — all five items
- Character correction understood and applied to architecture
- Research plan finalized — gap analysis complete
- iCloud bridge fully designed (structure, schemas, triggers, cadence)
- Project directories created
- Research pull executed — 94,000+ words of transcript content
- Web articles saved — Munger, Grove, Campbell
- Behind the Build article initiated (this document)

**Architecture locked:**
- iOS app: Swift 6, SwiftUI, iOS 18+
- Voice: OpenAI Whisper (in) + OpenAI TTS onyx 0.92 (out)
- Context: two-layer system prompt (character fixed, knowing variable)
- Bridge: iCloud Drive inbox/outbox with Stop + PostToolUse hooks
- No TestFlight (free Apple Developer account) — judge testing via simulator + Loom walkthrough

**Open:**
- iOS Xcode project not started
- ICM folder files not written (waiting on book extraction pass)
- Seneca, Aurelius, Naval Almanack — public domain fetch still pending

---

### 2026-05-21 — Day 1, Update 2 (loop fired)

The books arrived. Not from an upload — they were already here.

A search across the local library turned up nine of the critical books already on disk. The Effective Executive (Drucker), Trillion Dollar Coach (Campbell), The Score Takes Care of Itself (Walsh), Radical Candor (Kim Scott), The Hard Thing About Hard Things (Horowitz), Creativity Inc. (Catmull), Poor Charlie's Almanack, Thinking Fast and Slow (Kahneman), and Five Dysfunctions of a Team (Lencioni) — all present, in EPUB, MOBI, or PDF format. High Output Management was already in the operator reading stack as a PDF. All five Robert Greene books were in the frameworks folder, some in duplicate across multiple locations.

The only three books not found anywhere: Seneca's Letters from a Stoic, Marcus Aurelius's Meditations, and the Naval Almanack. All three are public domain or freely licensed. They can be fetched without an upload.

The research pull ended with 94,309 words of transcript content across thirteen cleaned text files — Naval Ravikant's three-hour podcast, both Munger sessions (DJCO 2023 and the Psychology of Misjudgment), the full Robert Greene Laws of Human Nature interview, the Acquired Intel episode, Kim Scott on Radical Candor, Bill Walsh on the Standard of Performance, Fred Rogers before the Senate, Andy Grove at Stanford, George Marshall on leadership, Ben Horowitz on the hard thing. Plus three web articles fully processed: the Munger USC 2007 speech in full, Grove's HOM frameworks and quotes, Campbell's 33 principles.

The loop is now running. Every 20 minutes this document updates. The build proceeds.

**What changed this update:**
- All critical books confirmed present on disk — no upload needed for 9 of 12
- Research manifest created at `08_KNOWLEDGE/_BRIEFS/praeceptor/articles/RESEARCH_MANIFEST.md`
- 20-minute auto-update loop live (CronCreate job `bb0408e2`)
- Behind the Build article initialized and first update complete

**Next immediate actions:**
1. Extract text from the 9 confirmed books (Calibre + gemma.sh pipeline)
2. Fetch Seneca, Aurelius, Naval Almanack (public domain)
3. Start iOS Xcode project scaffold
4. ICM folder build begins once book extraction produces reference material

---

### 2026-05-21 — Day 1, Update 3 — The Research Is Done. The ICM Is Built.

Two significant things happened in this session that changed the build's shape.

The first was a discovery about the extraction pipeline. The gemma.sh extract mode was capped at 300 output tokens — producing 244-word outputs from books with 200K+ words. The Ollama calls with larger context windows either timed out or read only the first 4,096 tokens of each book before stopping. The pipeline that looked like it was working — the 13K-word "extracted" files from Batch 1 — was actually Ollama timing out and returning the raw book text. Not a failure, as it turned out. The raw text is perfectly usable source material for the ICM build. But the extraction approach was abandoned for a simpler one: copy the first 100K chars of each book directly. Thirteen books, all converted and staged.

The second was the NotebookLM skill.

A full programmatic NotebookLM notebook was built in-session: 25 sources uploaded (12 transcripts, 11 book excerpts, 3 web articles), all indexed and ready in under 20 minutes. Seven targeted question blocks ran against the full corpus:

1. **[IDENTITY → QUOTES]** — Specific, memorable quotes from all 8 composite figures with context. Grove's "Those are lousy answers — be in my office in a week with better ones." Munger's Iron Prescription. Campbell's "Ben, it's not the money." Walsh's "Stand up, boy; stand up and fight." Seneca's "Nothing, Lucilius, is ours, except time." Aurelius's morning preparation. Naval's "Escape competition through authenticity."

2. **[RULES → SESSION STRUCTURE]** — How they actually ran coaching sessions. Campbell's five words on a whiteboard. Grove's ninety-minute 1:1 doctrine. Kim Scott's "solicit feedback before giving it" rule. The Elephant Strategy. Free-form listening. What they never did.

3. **[REFERENCE → FRAMEWORKS]** — Every named framework with behavioral rules. Grove's OKRs and Task-Relevant Maturity. Munger's Latticework and Inversion and Planck vs. Chauffeur Knowledge. Kim Scott's four quadrants by name (Radical Candor / Obnoxious Aggression / Manipulative Insincerity / Ruinous Empathy). Naval's Specific Knowledge and Leverage Types. Walsh's Standard of Performance. Seneca's Time Ownership. Aurelius's Morning Practice.

4. **[EXAMPLES → FAILURE STORIES]** — Goodfriend at Salomon. Kim Scott's ten months with Bob. Intel's $70 billion returned instead of reinvested. The oil companies buying fertilizer because one did. Munger's five cognitive biases with specific failure mechanisms.

5. **[IDENTITY → VOICE REGISTER]** — How each figure actually sounds. Grove: short, sharp, binary diagnostics ("capability or motivation — those are your only two levers"). Munger: blunt, oblique, multidisciplinary stitching with colorful metaphors. Campbell: informal, layered, relational, questions over statements. Walsh: detailed, clinical, architectural precision. Seneca: urgent, imperative, stark. Aurelius: private, weary, austere maxims, relentless self-monitoring. Naval: information-dense aphorisms, first-principles.

6. **[RULES → NEVER]** — Specific non-negotiables and refusals from each figure. Grove: never outsource training, never tolerate non-performers in important jobs. Munger: never hold an opinion without knowing the strongest argument against it. Campbell: never tell people what to do, never coach the uncoachable. Walsh: no caste systems. Scott: never sandwich feedback between false positives. Munger's guaranteed failure list: sloth, unreliability, envy, self-pity, denial.

7. **[IDENTITY → SEEING CLEARLY]** — How they cut through self-deception. Grove's variable inspection and "cutting windows into the black box." Munger's Inversion and the Iron Prescription. Campbell's Elephant Strategy and free-form listening. Seneca's daily digestion and mortality meditation. Aurelius's delineation — strip every object bare and naked. Naval's Feynman Test and "Reality is neutral — reality has no judgments."

All seven outputs saved as files in `08_KNOWLEDGE/_BRIEFS/praeceptor/notebooklm-outputs/`.

Then the ICM folder was built.

Twelve files written from scratch, drawing from the brainstorm, the Category 4 Intelligence document, and the NotebookLM research outputs. The ICM has a two-layer architecture: CHARACTER (fixed, permanent, everything in identity.md + rules.md + voice/) and KNOWING (variable, per session, ≤800 tokens). The CHARACTER layer defines who The Praeceptor is. The KNOWING layer tells him who he's talking to. The two are kept separate by design. KNOWING informs his judgment — it does not change his character.

**Files built:**
- `CLAUDE.md` — system entry point, read order, two-layer architecture, Rule 0
- `identity.md` — the composite, the eight figures with what each carries, his perspective, his voice, his seven blind spots
- `rules.md` — always/never tables, output format by situation, tone, routing table
- `examples.md` — three BAD outputs (the mirror, the explainer, the over-explainer) + three GOOD outputs + Rule 0 firing protocol
- `patterns-pending.md` — living catch file, empty, initialized
- `voice/signature-questions.md` — all five questions with delivery notes, triggers, and the principle behind each
- `voice/blind-spots.md` — all seven patterns with how he sees each, how he works with it, the question it leads to
- `voice/failure-stories.md` — five sourced failure stories (Goodfriend, Kim Scott's Bob, Intel, the Consistency Trap, the Oil Companies) with deployment instructions
- `voice/refusals.md` — four absolute refusals with what they look like in practice and the line he will not cross
- `intake/protocol.md` — ingest first, questions second, gap-specific questions only, KNOWING layer schema
- `intake/knowing-layer.md` — JSON schema with all fields, rules for writing, a filled example

**What changed this update:**
- All 13 books converted and staged as reference material
- Seneca and Aurelius resolved (public domain downloads completed earlier)
- Kim Scott and Campbell EPUBs resolved (iCloud sync bypass via /tmp copy)
- NotebookLM notebook built: 25 sources, 7 question blocks, 7 output files
- Full ICM folder written: 12 files, 88KB
- Research phase complete

**Open:**
- iOS Xcode project not started — this is the next action
- README.md, WRITEUP.md, QUICK-START.md not written
- Example session outputs not generated
- Loom walkthrough not recorded
- iCloud bridge hooks not written

---

---

### 2026-05-21 — Day 1, Update 4 — The App Builds.

The iOS application is complete and compiles clean.

Seventeen Swift files written across six architectural layers. The project was generated with xcodegen from a `project.yml` spec. One compilation error on first build — the `onChunk` callback in `ClaudeService` violated Swift 6's strict concurrency model by passing a non-`@Sendable` closure across actor boundaries. Replaced with `AsyncThrowingStream<String, Error>` — the idiomatic Swift 6 streaming pattern. The `SessionPhase` enum needed `Equatable` conformance for SwiftUI `.animation` bindings. Both fixes took under two minutes. Second build: `** BUILD SUCCEEDED **`.

**What was built:**

*ICM Folder (12 files):*
- `CLAUDE.md` — system entry point, two-layer architecture, Rule 0
- `identity.md` — the composite, eight figures with what each carries, his perspective, voice, seven blind spots
- `rules.md` — always/never tables, output format by situation, routing table
- `examples.md` — three BAD outputs + three GOOD outputs + Rule 0 firing protocol
- `patterns-pending.md` — living catch file
- `voice/signature-questions.md` — all five with delivery notes, triggers, the principle behind each
- `voice/blind-spots.md` — all seven with how he sees each, how he works with it, the question it leads to
- `voice/failure-stories.md` — five sourced failure stories with deployment instructions
- `voice/refusals.md` — four absolute refusals with the line he will not cross
- `intake/protocol.md` — ingest first, questions second, gap-specific only
- `intake/knowing-layer.md` — JSON schema, rules, filled example

*iOS App (17 Swift files):*
- `PraeceptorApp.swift` — app entry, AVAudioSession configuration
- `ContentView.swift` — root routing (settings → intake → session)
- `Session.swift` — ChatMessage, SessionPhase (Equatable), TimeOfDay with TTS speeds
- `KnowingLayerModel.swift` — full schema with `toCompressedContext()` serialization
- `SessionStore.swift` — messages, intake state, iCloud bridge reference
- `SessionViewModel.swift` — voice pipeline orchestrator (record → transcribe → stream → speak)
- `APIKeyManager.swift` — Keychain storage for Claude + OpenAI + ElevenLabs keys
- `AudioRecorder.swift` — AVAudioRecorder, 16kHz WAV, level metering
- `AudioPlayer.swift` — AVAudioPlayer with async completion handler
- `WhisperService.swift` — OpenAI Whisper API multipart form upload
- `ClaudeService.swift` — Claude API via AsyncThrowingStream (Swift 6 streaming)
- `TTSService.swift` — OpenAI TTS, onyx voice, configurable speed
- `SystemPromptBuilder.swift` — CHARACTER layer (full ICM inline) + KNOWING layer assembly
- `KnowingLayer.swift` — iCloud/Documents persistence bridge
- `TimeOfDayTheme.swift` — morning/noon/night color systems
- `HoldToSpeakButton.swift` — hold-to-speak with audio level visualization
- `SessionView.swift` — main voice UI, streaming bubbles, phase indicators
- `IntakeView.swift` — 7-step intake flow building the KNOWING layer
- `SettingsView.swift` — API key entry (Keychain-backed)

*Competition submission files:*
- `README.md` — sales page format, the distinction that governs everything
- `WRITEUP.md` — three-paragraph argument (the brief, the research, the app)
- `QUICK-START.md` — 5-minute judge setup

**What's still open:**
- `outputs/` folder — example session transcripts (elevation stack Layer 3)
- GitHub repository — needed for competition submission
- LICENSE file
- Loom walkthrough recording
- Final submission to Skool community

**Deadline:** Sunday May 24, 12:00 PM EST. 1-hour buffer target: 11:00 AM EST.
**Time remaining:** ~60 hours from time of this update.

---

---

### 2026-05-21 — Day 1, Update 5 — The Examples Are Written.

The `outputs/` folder is done. Three example sessions, each a demonstration of a different behavioral pattern.

**Session 01 — The Gap Question.** Marcus, a software consulting firm founder, has been "refining" a pitch deck for four months with zero investor meetings. The Praeceptor traces the story in four exchanges — two practice runs, last one two months ago, no testing since. The question that lands: "What would you tell someone else in your exact position?" He answers himself. Three outreach emails scheduled before the session ended.

**Session 02 — The Bar Quietly Lowered.** Daniela, Session 4. She opened by framing "$10K MRR" as her new milestone — without ever announcing that she'd dropped the $50K goal from Session 1. The Praeceptor surfaced it: not "why did you lower the bar" — just "what changed." She arrived at the answer herself. *March was a useful failure. It told you the paid acquisition model needs more testing before you scale it. That's not a reason to revise the destination. It's data about the route.*

**Session 03 — The Refusal.** Jordan, Session 6. Same co-founder obstacle every session. Each time, clarity reached, decision to "have the conversation" made, conversation not happening. The Praeceptor named it explicitly: *I think you've decided that protecting the relationship with your co-founder is worth more than resolving the business problem.* The refusal wasn't to Jordan — it was to the session. If the conversation hasn't happened by next time, they're talking about something else. The last question: "What's your first sentence when you start that conversation?" He can't leave without having said it out loud.

Three sessions. Three different moves. The gap question, the bar catch, the refusal. All three written in The Praeceptor's voice — short sentences, no hedging, no performance.

**What changed this update:**
- `outputs/session-01-the-gap-question.md` — complete
- `outputs/session-02-the-bar-lowered.md` — complete
- `outputs/session-03-refusal-uncoachable.md` — complete
- Elevation stack Layer 3 (example outputs) fully built

**What's still open:**
- GitHub repository
- LICENSE file
- Loom walkthrough recording
- Final submission to Skool community

**Deadline:** Sunday May 24, 12:00 PM EST. 1-hour buffer target: 11:00 AM EST.

---

---

### 2026-05-21 — Day 1, Update 6 — The Repository Is Live.

The GitHub repository is up: **https://github.com/orteug/the-praeceptor**

43 files, 3,709 lines. Clean initial commit. Everything in — the ICM folder, the iOS app (full Swift source + Xcode project), the competition submission files, the example session outputs, the build log.

The `.gitignore` was written to cover Xcode-specific artifacts: xcuserdata, build directories, DerivedData, CocoaPods, SPM caches. The `.xcodeproj` itself went in — judges need it to build. User-specific data excluded. The MIT LICENSE is in the root. The repo description follows the `agency-os` pattern: one sentence, direct.

The pattern here is the same as Week 4. `orteug/agency-os` was the folder that won. `orteug/the-praeceptor` is the folder that has an app attached to it.

**What changed this update:**
- `.gitignore` written — Xcode artifacts excluded, secrets excluded
- `LICENSE` written — MIT, 2026
- Git repository initialized in `praeceptor/` root
- Initial commit: 43 files, 3,709 insertions
- `orteug/the-praeceptor` created as public repo on GitHub
- Pushed to `origin/main`

**What's still open:**
- Loom walkthrough recording — requires simulator running
- Final submission post to The Lyceum Skool community

**Deadline:** Sunday May 24, 12:00 PM EST. 1-hour buffer target: 11:00 AM EST.

---

---

### 2026-05-21 — Day 1, Update 7 — Design Brief Written.

The build is pausing on implementation to bring in visual design. A `design-brief.md` was written and dropped at the praeceptor root — a complete spec intended for a design AI to consume without context from this session.

The brief covers four screens (Settings, Intake, Session, root routing), all three time-of-day themes with exact RGB seed values, every element in the hold-to-speak button and its phase-driven states, the real-time pulse ring behavior, typography current state and open questions, and a clear partition between what the designer has latitude on and what cannot change.

The hardest part to communicate was the character constraint — not aesthetic preference, but character. The brief opens with two sections before touching any screen: what this app is, and what it must not feel like. The second section is longer. No coaching startup gradients. No wellness app softness. No productivity tool dashboard logic. The reference is not an app — it's a room. A mentor's study.

The design AI gets the brief plus the pulled inspiration. The output — color specs, font decisions, layout — comes back to be wired into the existing SwiftUI view files. The implementation layer is already built and waiting. This is purely a visual pass.

One technical note included for whoever implements the design: the pulse ring's `animation(.easeOut(duration: 0.05))` is functional, not decorative. It responds to live microphone audio level in near-real-time. Any design that slows it to an ambient pulse loses the feedback that tells the user they're actually being heard.

**What changed this update:**
- `design-brief.md` written — 4 screens, 3 themes, full spec, implementation handoff format
- Repo is live at github.com/orteug/the-praeceptor
- Build is in design hold — implementation resumes when design output returns

**What's still open:**
- Design output — inspiration pass in progress
- Loom walkthrough — requires simulator running
- Final submission to The Lyceum Skool community

**Deadline:** Sunday May 24, 12:00 PM EST. 1-hour buffer target: 11:00 AM EST.
**Time remaining:** ~58 hours.

---

---

### 2026-05-21 — Day 1, Update 8 — Security Pass. Repo Is Clean.

Before this build goes further, a full scan of every public-facing file for sensitive data. The repo went up before that pass ran. Six things found, six things fixed, committed and pushed.

**What was found and removed:**

The most significant: the `intake/knowing-layer.md` example was populated with real data — real name, real financial position, real current project. The example exists to show the schema in use. It should have been fictional from the start. It's now a fully fleshed-out fictional persona — Marcus, a software consulting founder, four months into a pitch deck refinement loop with no investor conversations started. The example is better for it. A fictional person in a plausible, specific situation demonstrates the schema more usefully than the real thing would have.

The LICENSE had a full legal name. Changed to "The Praeceptor Contributors."

The iOS bundle identifier was `com.meinc.praeceptor` in both `project.yml` and `APIKeyManager.swift` — the Keychain service name. Changed to `com.praeceptor` and `com.praeceptor.app`. The app builds with this identifier. Anyone cloning the repo won't see a trace of the internal brand.

The build log itself had a name appearing eleven times across four updates — in process notes about authorization, Loom recording, design handoffs. All stripped. The references to internal infrastructure (`CC_INBOX`, `MeInc operator library`) in Update 2 were rewritten to read as any builder's local library.

`patterns-pending.md` had a single name reference in the review cadence note. Removed.

The scan after the pass returned zero results. The push is clean.

**What this changed about the build:**
Nothing functional. The app behavior is identical. The Keychain service name change means anyone who had previously entered keys under the old service identifier would need to re-enter them — but no one had, this is a fresh build.

**What's still open:**
- Design output — inspiration pass in progress
- Loom walkthrough
- Final submission to The Lyceum Skool community

**Deadline:** Sunday May 24, 12:00 PM EST.

---

*Last updated: 2026-05-21 — auto-loop active every 20 min (job bb0408e2)*
*Next: design output returns → implement into SwiftUI → Loom → submission*
