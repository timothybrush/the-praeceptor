# Demo Production Config

## Voice
- Provider: ElevenLabs
- Voice ID: 6sFKzaJr574YWVu4UuJF
- Speed: 0.92 (apply via ElevenLabs stability/style settings)

## API Keys needed (provide when at machine)
- ElevenLabs API key → generates narration audio
- OpenAI API key → optional, for app demo recording with onyx TTS active
- Anthropic API key → required for live app session recording

## Scripts
- demo-script.md → ~3:25, 8 segments
- judge-guide-script.md → ~2:20, 7 segments
- announcement-script.md → ~1:30, 4 narration lines + visual sequence

## Video assembly
- Tool: ffmpeg (installed)
- Output: MP4 per video, then YouTube upload
- Announcement: silent fragment sequence + narration over P. mark
- Screenshots: /tmp/praeceptor-screenshots/ (existing), simulator UDID 9504D39C-A773-4CBF-9B14-124D1E237F47

## YouTube channel
- Channel name: The Praeceptor (to be created)
- Videos: Announcement → Demo → Judge Guide (upload order)
