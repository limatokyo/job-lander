# Job Lander 🎯

**A dual-agent job-application co-pilot that finds the right jobs, tailors your resume to each, and emails you a ready-to-apply packet — end to end, with you in control at every decision.**

Built as a [Claude Code](https://claude.com/claude-code) skill. Two specialist agents behind a thin orchestrator, backed by a Google Sheet (memory) and Gmail (delivery), searching **LinkedIn + Indeed + Glassdoor** via Google for Jobs.

---

## The 60-second version

Job searching forces a bad trade-off: **apply broadly with a generic resume that gets filtered out, or tailor each resume by hand (30–60 min each) and apply to only a few.** Job Lander removes the trade-off:

1. **Job Finder** (Agent 1) searches fresh postings across LinkedIn/Indeed/etc., scores each against your résumé, and hands you a ranked shortlist.
2. You **approve** which to pursue.
3. **Resume Customizer** (Agent 2) asks a few clarifying questions (once, batched), then tailors your résumé to each approved job — restructuring your *real* experience, never fabricating.
4. You get an **email with every tailored résumé + apply link**. You click apply.

Two agents. Three human gates. Real memory. Real delivery. Zero fabrication. Free to run.

## Why it's different
- **Dual-agent, not a single prompt** — a manager orchestrates two specialists with a clean handoff.
- **Human-in-the-loop by design** — three approval gates (shortlist, clarifying questions, apply) keep judgment with the person.
- **Anti-fabrication is a feature** — Agent 2 *asks* rather than inventing when the résumé doesn't cover a JD requirement.
- **Generalized** — everything person-specific lives in one `profile.json`; swap it and Job Lander works for any seeker.
- **Real infrastructure, free** — self-hosted Google Workspace MCP for Sheets + Gmail, SerpApi Google Jobs for LinkedIn-level coverage. No paid automation platform.

## What's in this repo
| Path | What |
|---|---|
| [`docs/PRFAQ.md`](docs/PRFAQ.md) | Press-release + FAQ (the "why") |
| [`docs/user-journey.md`](docs/user-journey.md) | Product design: the end-to-end user journey |
| [`docs/architecture.md`](docs/architecture.md) | One-page architecture + how the workflow runs |
| [`docs/impact-statement.md`](docs/impact-statement.md) | Problem, audience, impact, value |
| [`docs/INSTALL.md`](docs/INSTALL.md) | **Install Job Lander into your own Claude** |
| [`slides/architecture-slide.html`](slides/architecture-slide.html) | One-page architecture slide (open in a browser) |
| [`slides/pitch-deck.html`](slides/pitch-deck.html) | Differentiation pitch deck |
| [`skill/`](skill/) | The installable skill (orchestrator + both agents) |

## Quick start
See [`docs/INSTALL.md`](docs/INSTALL.md). In short: drop the `skill/` folder into your Claude skills directory, connect a Google Workspace MCP + a SerpApi key, fill `profile.json`, and say **"run Job Lander."**

## Status
Built and demoed end-to-end (search → shortlist → approve → clarify → tailor → emailed packet) on live 2026 postings. See the demo video linked in the submission.

## License
MIT — see [`LICENSE`](LICENSE).
