# Job Lander 🎯

**A dual-agent job-application co-pilot.** Job Lander automates the two most draining parts of a job search — *finding* the right fresh postings and *tailoring* a resume to each — end to end, while keeping the human in control of where they apply.

Built for the AI hackathon by chaining two specialist agents behind a thin orchestrator, backed by a Google Sheet (memory) and Gmail (delivery) through a self-hosted Google Workspace MCP server.

---

## The problem
A tailored resume is a candidate's biggest lever against hundreds of applicants — but tailoring costs 30–60 min each. Across dozens of applications that forces a bad trade-off: apply broadly with a generic resume that gets filtered out, or apply selectively and miss opportunities. And that's after the daily grind of scanning job boards just to *find* the right roles.

## The solution
Two agents, one manager, three human gates:

- **Agent 1 — Job Finder** aggregates fresh postings, scores each against the seeker's resume, dedupes against memory, and returns the **top X best-fit jobs** with a transparent ranking.
- **Agent 2 — Resume Customizer** tailors the resume to each **approved** job — restructuring the seeker's *real* experience (never fabricating) — and produces a one-page `.docx` + PDF.
- **Orchestrator** manages the handoff, the gates, the memory, and the delivery, then **emails the seeker a ready-to-apply packet.**

## The three guardrail gates
1. **Shortlist approval** — the seeker approves *which* jobs proceed before any tailoring.
2. **Batched clarifying questions** — before tailoring, the Customizer asks (in one consolidated pass) about every gap it would otherwise assume, so gaps are filled with *real* answers, not invention. This is the anti-fabrication gate.
3. **Apply stays manual** — Job Lander never submits an application or contacts an employer. It hands over resume + link and stops.

## Architecture
```
   profile.json ─┐
   resume.docx ──┤   Job Lander (orchestrator)  ◀── Google Sheet (memory / dedupe)
                 └────────────┬────────────────
                              │ delegates
        ┌─────────────────────┼──────────────────────┐
        ▼                                             ▼
  Agent 1: Job Finder                        Agent 2: Resume Customizer
  search → score → dedupe                    batched Qs → tailor per job
        │ shortlist                                  │ .docx + PDF
        ▼                                            ▼
   GATE 1: approve ───────▶ GATE 2: answers ───▶ packet ──▶ Gmail send (to seeker)
                                                       GATE 3: seeker applies
```

## Generalized for any seeker
Everything seeker-specific lives in **`profile.json`** — resume path, target roles, locations, work authorization, notify email, memory sheet id. The agents and orchestrator are generic. Swap the profile and Job Lander works for anyone. (`profile.json` ships populated with the demo seeker; `profile.template.json` is the blank schema.)

## Files
```
job-lander/
├── SKILL.md                 Orchestrator (the manager agent) — entry point
├── profile.json             Demo seeker profile (the only seeker-specific file)
├── profile.template.json    Blank schema for any new seeker
├── agents/
│   ├── job-finder.md        Agent 1 — discovery & ranking
│   └── resume-customizer.md Agent 2 — tailoring (batched Qs + per-job)
└── README.md                This file
```

## Infrastructure (already set up)
- **Memory:** Google Sheet "Job Lander Log" (`date_seen | title | company | link | fit_score | status`).
- **Delivery:** Gmail **send** (real send, to the seeker only) — via a self-hosted **Google Workspace MCP** server (`workspace-mcp`, run through `uvx`, transport `stdio`). Free, no third-party automation platform.
- **Job search:** **SerpApi Google Jobs** (primary) via `agents/serpapi.sh` — wraps Google for Jobs, so one call spans **LinkedIn + Indeed + Glassdoor + company sites** with full descriptions (free tier: 100 searches/mo). Connected **Indeed MCP** is the fallback.

## How to run
In Claude Code, say **"run Job Lander"** or **/job-lander**. The orchestrator loads the profile, runs Agent 1, pauses for your approval (Gate 1), asks its batched questions (Gate 2), tailors each approved resume with Agent 2, and emails you the packet. You review and apply (Gate 3).

**Fallback:** if the job search returns nothing, paste a JD or link directly and Agent 2 will still tailor a resume — so the tailoring half always demos.
