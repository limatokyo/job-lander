# Product Design — User Journey

Job Lander is designed around one principle: **automate the exhausting middle, keep the human at every real decision.** The journey below shows where the system works autonomously (⚙️) and where it hands control back to the seeker (🧑 = a human gate).

## The end-to-end journey

```
 ONBOARD (once)           SEARCH & RANK            APPROVE            CLARIFY             TAILOR              DELIVER            APPLY
 ────────────────    ───────────────────────    ───────────    ────────────────    ───────────────    ───────────────    ──────────
 🧑 Answer a short   ⚙️ Agent 1 searches        🧑 GATE 1       🧑 GATE 2            ⚙️ Agent 2         ⚙️ Emails you the   🧑 GATE 3
 questionnaire →     LinkedIn/Indeed/etc.,      Review the      Answer a batched     tailors your       packet: every       You click
 saved to profile    scores vs. your résumé,    ranked          set of clarifying    résumé to each     résumé + apply      apply on the
 (never re-asked).   dedupes, ranks top X.      shortlist;      questions (once)     approved job       link, logged to     roles you
                                                approve which   for gaps it won't    (.docx + PDF).     the memory sheet.   choose.
                                                to pursue.      guess at.
```

## Stage by stage

### 1. Onboard — once 🧑
On first run, a short questionnaire captures what a résumé *doesn't* reliably say:
- **Target titles** (what you want next, not just past roles)
- **Locations + work model** (onsite / hybrid / remote)
- **Work authorization** — two parts: authorized now without sponsorship? need sponsorship in the future?
- **Recency window** (how fresh; default 3 days)
- **Seniority level + ceiling** (e.g. IC only, "not Director+")
- *(Optional)* salary floor, exclusions

Answers save to `profile.json`. **Every later run just asks "anything to update?"** — one yes/no instead of re-answering everything.

### 2. Search & rank — Agent 1 (Job Finder) ⚙️
Searches each target role across the seeker's locations via **SerpApi Google Jobs** (LinkedIn + Indeed + Glassdoor + company sites, full descriptions). Applies hard filters (location, role, **seniority ceiling**, **sponsorship**, salary floor), scores each survivor 0–10 on a weighted rubric (skills, transferability, seniority fit, domain), dedupes against the memory sheet, and returns a ranked shortlist. **Never pads** the list to hit a number.

### 3. Approve — GATE 1 🧑
The seeker sees the ranked shortlist (title · company · score · why-it-fits · the one gap) and approves which to pursue. Only approved jobs proceed. *This keeps the human owning where they apply, and prevents wasted tailoring effort.*

### 4. Clarify — GATE 2 (batched) 🧑
Before writing anything, Agent 2 scans every approved job against the résumé and asks **one consolidated set** of questions for gaps it would otherwise have to assume. Gaps get filled with **real answers**, never invention. Batching keeps it to a single interruption instead of one per job. *This is the anti-fabrication gate.*

### 5. Tailor — Agent 2 (Resume Customizer) ⚙️
For each approved job, tailors the résumé from the seeker's real content + their answers, applying writing rules that make it read human (no AI clichés, impact-led bullets, one page), and produces a **.docx + PDF** plus an honest recruiter fit ranking.

### 6. Deliver ⚙️
Assembles the packet and **auto-sends one email** to the seeker: every tailored résumé attached, paired with its apply link and a recruiter read. Safe to auto-send because it goes to the seeker, never to an employer. Each job's status advances in the memory sheet.

### 7. Apply — GATE 3 🧑
The seeker reviews and applies to the roles they choose. Job Lander never submits on their behalf.

## Design principles
- **Human at every irreversible or judgment-heavy step** — three gates, not zero.
- **Batch interruptions** — ask everything at once, not per job.
- **Honesty over volume** — no padding, gaps flagged, "only N cleared the bar" stated plainly.
- **One config, any seeker** — the product is generic; the person is data.
- **Graceful failure** — if search returns nothing, paste a JD and tailoring still works.
