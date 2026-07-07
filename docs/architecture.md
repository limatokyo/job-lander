# Architecture — How Job Lander Works

Job Lander is an **orchestrator + two specialist agents**, backed by external memory (Google Sheet) and delivery (Gmail), pulling jobs from Google for Jobs. A visual version is in [`slides/architecture-slide.html`](../slides/architecture-slide.html).

## One-page diagram

```
   ┌───────────────┐        ┌──────────────────────────────────────┐
   │  profile.json │        │        JOB LANDER  (orchestrator)      │      ┌────────────────────┐
   │  résumé .docx │──────▶ │  the "manager" agent — owns the flow,  │◀────▶│  Google Sheet       │
   └───────────────┘        │  the 3 human gates, memory & delivery  │      │  (memory / dedupe)  │
                            └───────────────┬──────────────────────┘      │  seen→approved→sent │
                                            │ delegates                    └────────────────────┘
              ┌─────────────────────────────┼─────────────────────────────┐
              ▼                                                             ▼
   ┌────────────────────────┐                                  ┌────────────────────────────┐
   │ AGENT 1 — Job Finder    │                                 │ AGENT 2 — Resume Customizer │
   │ search → score → dedupe │                                 │ batched Q's → tailor per job│
   │                         │                                 │                             │
   │  ┌───────────────────┐  │                                 │  résumé = source of truth   │
   │  │ SerpApi Google    │  │   structured shortlist          │  never fabricates           │
   │  │ Jobs (LinkedIn +  │──┼──▶ [{title,company,link,        │  outputs .docx + PDF        │
   │  │ Indeed + more)    │  │      jd,score,gap}]              │                             │
   │  └───────────────────┘  │                                 └──────────────┬──────────────┘
   └───────────┬─────────────┘                                                │
               ▼                                                              ▼
          🧑 GATE 1                      🧑 GATE 2 (batched clarifying Q's)   application packet
          approve shortlist  ───────────────────────────────────────────▶   │
                                                                              ▼
                                                              ┌────────────────────────────┐
                                                              │  Gmail  (auto-send to seeker)│
                                                              │  résumés + apply links       │
                                                              └──────────────┬───────────────┘
                                                                             ▼
                                                                       🧑 GATE 3
                                                                    seeker applies (manual)
```

## Components

| Component | Role | Implementation |
|---|---|---|
| **Orchestrator** | Manager agent: loads profile, runs the flow, enforces the 3 gates, owns memory + delivery | `skill/SKILL.md` |
| **Agent 1 — Job Finder** | Discovery & ranking: search, hard-filter, score, dedupe | `skill/agents/job-finder.md` |
| **Agent 2 — Resume Customizer** | Tailoring: batched clarifying questions, then per-job résumé | `skill/agents/resume-customizer.md` |
| **Profile** | The only seeker-specific config (résumé path, titles, locations, authorization, seniority, delivery) | `skill/profile.template.json` |
| **Job source** | LinkedIn + Indeed + Glassdoor + company sites, full JDs | SerpApi Google Jobs (`skill/agents/serpapi.sh`) |
| **Memory** | Dedupe + auditable job log | Google Sheet via Google Workspace MCP |
| **Delivery** | Auto-send the packet to the seeker | Gmail via Google Workspace MCP |
| **Runtime** | Executes the agents & tools | Claude Code (LLM orchestration) |

## Data flow (one run)
1. **Load** — orchestrator reads `profile.json` + the résumé, and the memory sheet (for dedupe).
2. **Search** — Agent 1 queries SerpApi Google Jobs per role×location (date-filtered), gets full JDs.
3. **Filter + score + dedupe** — hard filters (location, role, seniority ceiling, sponsorship, salary), weighted 0–10 score, drop already-seen. → ranked shortlist.
4. **Gate 1** — seeker approves; approved + seen jobs written to the sheet.
5. **Gate 2** — Agent 2 returns one batched question set; seeker answers.
6. **Tailor** — per approved job, Agent 2 writes a `.docx`, converts to PDF (LibreOffice), + recruiter ranking.
7. **Deliver** — orchestrator emails the packet (Gmail), advances sheet status to `sent`.
8. **Gate 3** — seeker applies manually.

## Tech stack
- **Claude Code** — agent runtime / LLM orchestration
- **SerpApi Google Jobs** — job discovery (Google for Jobs → LinkedIn/Indeed/Glassdoor), full JDs
- **Google Workspace MCP** (self-hosted, `workspace-mcp` via `uvx`, stdio) — Sheets (memory) + Gmail (delivery)
- **python-docx** — résumé generation from the standard résumé (preserves formatting)
- **LibreOffice** (headless) — `.docx` → PDF

## Key design decisions
- **SerpApi over scraping LinkedIn** — compliant, robust, full descriptions.
- **Self-hosted Google MCP over Zapier** — free, no trial clock, first-party control.
- **Batched Gate 2** — one interruption, not one per job.
- **Profile-driven generalization** — the product is generic; the seeker is a config file.
- **Auto-send is safe** — the packet goes to the seeker only; applying stays manual.
