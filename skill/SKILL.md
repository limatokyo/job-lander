---
name: job-lander
description: >-
  Job Lander is a dual-agent job-application co-pilot. It finds the best fresh jobs for a seeker,
  gets their approval, tailors their resume to each approved job, and emails them a ready-to-apply
  packet — automating the whole search-and-tailor pipeline while keeping the human in control.
  Use whenever the seeker says "run job lander", "/job-lander", "find and tailor", "do my job search
  and resumes", "land me some jobs", or asks to go from job search all the way to application-ready
  resumes in one flow. Orchestrates two specialist agents (Job Finder → Resume Customizer) with three
  human-approval gates, backed by a Google Sheet memory and Gmail delivery.
---

# Job Lander — Orchestrator (the manager agent)

Job Lander automates the two most draining parts of a job search — *finding* the right fresh postings and *tailoring* a resume to each — end to end, so the seeker applies selectively **and** at scale, without losing control over where they apply.

## What this skill is

This is the **orchestrator**. It does no searching or writing itself. It:
- Loads the seeker's **profile** (the only seeker-specific config).
- **Delegates** discovery to **Agent 1 — Job Finder** (`agents/job-finder.md`).
- **Delegates** tailoring to **Agent 2 — Resume Customizer** (`agents/resume-customizer.md`).
- Enforces the **three human-approval gates**.
- Owns the **memory** (Google Sheet) and **delivery** (Gmail packet).

It is generic: everything seeker-specific lives in `profile.json`, so Job Lander works for any job seeker, not one person.

## Source of truth: the profile

Read **`profile.json`** (in this skill's folder) at the start of every run. If it is missing or still has template placeholders, run **onboarding** first (see Step 0). Key fields: `seeker.resume_path`, `search.target_roles / locations / work_model / recency_days / top_x / min_fit_score`, `memory.spreadsheet_id / tab / columns`, `delivery.notify_email / mode`.

The seeker's **resume file** (`seeker.resume_path`) is the single source of truth for all resume content. **Never fabricate** anything not grounded in it or confirmed by the seeker.

## Tools this skill uses (Google Workspace MCP — self-hosted)

Load via `ToolSearch` if deferred (match by capability; server hash can change):
- **Memory (Google Sheet):** `mcp__google-workspace__read_sheet_values` (dedupe read), `mcp__google-workspace__modify_sheet_values` or `append_table_rows` (write log rows).
- **Delivery (Gmail):** `mcp__google-workspace__send_gmail_message` (sends the packet, supports attachments). This connector **can send** (not draft-only).
- **Job search:** **SerpApi Google Jobs** (`agents/serpapi.sh`, primary — LinkedIn + Indeed + more via Google for Jobs) + Indeed MCP (fallback) — used inside Agent 1.

All Google tools require `user_google_email` = `profile.seeker.email`.

---

## Procedure (run top to bottom)

### Step 0 — Profile: onboard once, confirm each run after
The profile is collected **once** and remembered in `profile.json`. Two branches:

**A) First run** (no `profile.json`, or it still has template placeholders): run the full questionnaire below with `AskUserQuestion`, then write `profile.json`.

**B) Every run after** (a filled `profile.json` exists): **do not re-ask the questionnaire.** Instead:
1. Show a **compact summary** of the saved preferences (titles · locations/work model · authorization · recency · seniority · any salary/exclusions) so the seeker sees what's set.
2. Ask once with `AskUserQuestion`: *"Anything to update before I run?"* — **No →** power through to Step 1. **Yes →** ask (multiSelect) *which* fields to change, collect new values for **only those**, rewrite `profile.json`, then continue.

This keeps every repeat run to a single yes/no unless something actually changed. (For the demo seeker the profile is already filled — go straight to the branch-B confirm.)

---

**First-run questionnaire — Required:**
1. **Standard resume** — path to the `.docx` to tailor from (the source of truth). → `seeker.resume_path`
2. **Target titles** — which roles to search (what they want *next*, not just past titles). → `search.target_roles`
3. **Locations + work model** — cities and onsite/hybrid/remote. → `search.locations`, `search.work_model`
4. **Work authorization (two parts — both matter):**
   - (a) Authorized to work now *without* sponsorship? → `authorized_now_without_sponsorship`
   - (b) Will you need sponsorship *in the future*? (e.g. F-1 OPT now, H-1B later) → `will_need_sponsorship_in_future`
   Both feed the sponsorship hard-filter — a posting that says "no sponsorship now **or** in future" is rejected when either applies.
5. **Recency window** — how far back to pull postings: 1 / 3 / 7 / 14 / 30 days (default **3** — 1 day is usually too thin). → `search.recency_days`
6. **Target seniority level** — allowed levels (e.g. Senior / Staff / Principal / Manager) and a ceiling (e.g. "not Director+"). → `search.seniority_levels`, `search.max_level_note`. This prevents strong-domain-but-wrong-level matches (the Expedia Director case) from surfacing.

**Optional (offer, let the seeker skip):**
7. **Minimum salary** — a hard floor, if any. → `search.min_salary`
8. **Exclusions** — industries or companies to avoid (e.g. a current employer). → `search.exclude`

Default `delivery.notify_email` to `seeker.email` and `top_x` to 5 unless the seeker says otherwise. Confirm the memory `spreadsheet_id` (create a sheet if needed). Write `profile.json` and continue.

### Step 1 — Load context
- Read `profile.json`.
- Extract the resume text from `seeker.resume_path` so scoring and tailoring reflect the latest resume.
- Read the memory sheet (`memory.spreadsheet_id`, tab `memory.tab`) into a set of seen keys for dedupe.

### Step 2 — Delegate to Agent 1: Job Finder  →  *discovery & ranking*
Run the full procedure in **`agents/job-finder.md`** using the profile. It returns a **structured shortlist**: the `top_x` best-fit new postings, each as:
```
{ title, company, location, link, jd_text, fit_score, top_strengths[1-2], one_gap }
```
plus a Top-10 ranking. Agent 1 dedupes against the memory sheet and never pads to hit a number.

### Step 3 — GATE 1: Shortlist approval (human-in-the-loop) — MUST EXECUTE
Present the ranked shortlist to the seeker (title · company · location · score · why-it-fits · the one gap), then **pause** with `AskUserQuestion`. The seeker approves all, deselects some, or adjusts `top_x`. **Only approved postings continue.**
> Why this gate: it keeps the human owning *where* they pursue, and prevents spending tailoring effort on bad-fit roles.

Write every posting Agent 1 analyzed to the memory sheet now (Step 7 detail), marking approved ones `approved` and the rest `seen`, so they're never re-recommended.

### Step 4 — GATE 2: Batched clarifying questions — MUST EXECUTE
Hand **all approved JDs + the resume** to Agent 2's *question-gathering* pass (`agents/resume-customizer.md` → "Batched questions"). Agent 2 scans every approved JD against the resume and returns **one consolidated set of questions** covering every gap it would otherwise have to assume (unlisted tools, missing metrics, project scope). Present them to the seeker in a **single pass** with `AskUserQuestion` and collect answers.
> Why this gate: this is the anti-fabrication guardrail — gaps get filled with *real* answers, never invented. Batching keeps it to **one** interruption instead of one per job.

If the seeker skips a question, that gap is accepted and flagged honestly in that resume's recruiter ranking — never papered over with a fabrication.

### Step 5 — Tailor: per-job loop → Agent 2: Resume Customizer
For each approved posting, run **`agents/resume-customizer.md`** with `(resume + that JD + the seeker's Step-4 answers)`. Each run returns a tailored **one-page resume (.docx + PDF)** saved to the workspace, plus a recruiter fit ranking. Accumulate all outputs into the **application packet**. Update each job's sheet row `status` → `tailored`.

### Step 6 — Deliver: assemble packet + send
Build the packet email and send it with `mcp__google-workspace__send_gmail_message` to `delivery.notify_email` (`mode: "send"`):
- **Subject:** `🎯 Job Lander: [N] tailored resumes ready — [Mon DD, YYYY]`
- **Body (HTML):** one block per approved job — **Title — Company** · Location · **Fit X.X/10** · **[Apply / View posting](link)** · one line on what was tailored.
- **Attachments:** every tailored resume (.docx and/or PDF). ⚠️ The Gmail server only reads files inside its permitted attachment dir **`C:\Users\limat\.workspace-mcp\attachments`** — copy each resume there and pass that path (or set `ALLOWED_FILE_DIRS` in the server config to include the workspace, which needs a restart). Alternatively pass the file as base64 `content`.

The email goes **to the seeker**, never to employers. After sending, update each job's `status` → `sent`.

> Auto-send is safe here precisely because the recipient is the seeker. **Applying** to a job is never automated — that stays the seeker's manual action (Gate 3, below).

### Step 7 — Memory write (Google Sheet)
Throughout the run, keep the log current in `memory.spreadsheet_id` / tab `memory.tab`, columns `date_seen | title | company | link | fit_score | status`:
- Append every analyzed job (dedupe on `company|title|location`, lowercased).
- Advance `status`: `seen` → `approved` → `tailored` → `sent`.
- Read this sheet at Step 1 so nothing is ever re-recommended.
Use `read_sheet_values` to load, `modify_sheet_values`/`append_table_rows` to write.

### Step 8 — Report back in chat
Tell the seeker: how many jobs cleared the bar, which were approved, that the packet email was sent (with the subject), where the resume files are, and the sheet link. If any tool failed or returned zero jobs, say exactly what happened — never fail silently.

---

## GATE 3: Apply stays manual (always)
Job Lander **never submits an application or contacts an employer.** It hands the seeker resume + link and stops. Submitting to an employer is irreversible and reputational — that decision is always the human's.

## Guardrails
- **Never fabricate** jobs, links, scores, metrics, or resume content. Only real tool output + the seeker's actual resume/answers.
- **Three gates are mandatory:** shortlist approval (Gate 1), batched clarifying questions (Gate 2), manual apply (Gate 3).
- **No padding** the shortlist to hit `top_x`.
- **Graceful failure:** on zero results or a tool error, still report exactly what happened. If Agent 1 finds nothing, offer the fallback: the seeker pastes a JD/link directly into Agent 2 so tailoring still works.
- **Profile-driven only:** all seeker specifics come from `profile.json`. Nothing about one seeker is hardcoded here.

## Architecture at a glance
```
                ┌──────────────────────────────┐
   profile.json │   Job Lander (orchestrator)  │  Google Sheet (memory)
   resume.docx ─▶│  loads profile + resume      │◀────── read/append rows
                └──────────────┬───────────────┘
                               │ delegates
        ┌──────────────────────┼───────────────────────┐
        ▼                                               ▼
  Agent 1: Job Finder                          Agent 2: Resume Customizer
  search → score → dedupe                      batched Qs → tailor per job
        │  shortlist                                    │  .docx + PDF
        ▼                                               ▼
   GATE 1: approve  ───────────▶  GATE 2: answers  ───▶ packet ──▶ Gmail send
                                                              (to seeker)
                                                        GATE 3: seeker applies
```
