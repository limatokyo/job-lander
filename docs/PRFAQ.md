# Job Lander — PRFAQ

*(Working-backwards format: an imagined launch announcement, followed by FAQs.)*

---

## PRESS RELEASE

### Job Lander turns a full day of job-hunting into a five-minute review

**A dual-agent co-pilot finds your best-fit jobs, tailors your résumé to each, and emails you a ready-to-apply packet — while you stay in control of every decision.**

Today we're releasing **Job Lander**, an AI job-application co-pilot that automates the two most draining parts of a job search — *finding* the right fresh postings and *tailoring* a résumé to each — end to end.

Job seekers face an impossible trade-off. A tailored résumé is the biggest lever they have against hundreds of applicants, but tailoring takes 30–60 minutes per role. So they either blast a generic résumé that gets filtered out, or tailor a handful and miss everything else. Job Lander removes the trade-off.

Here's how it works. Agent 1, **Job Finder**, searches the latest openings across LinkedIn, Indeed, and Glassdoor, scores each against your résumé, and hands you a ranked shortlist — with an honest note when only a few clear the bar. You approve the ones worth pursuing. Agent 2, **Resume Customizer**, then asks a short, one-time set of clarifying questions about anything your résumé doesn't cover, and tailors your résumé to each approved job by restructuring your *real* experience — never inventing anything. Minutes later, a single email lands in your inbox with every customized résumé and its apply link. You click apply.

"The magic isn't that it applies for you — it's that it does the exhausting middle work and hands you back the decisions that actually matter," said the creator. "It searches while you sleep, drafts while you focus, and never once makes something up on your behalf."

Job Lander runs as a Claude Code skill, is free to operate, and generalizes to any seeker by editing a single profile file. It's available today.

---

## FAQ

**Q: Does Job Lander apply to jobs for me?**
No — and that's deliberate. Submitting an application to an employer is irreversible and reputational, so that decision always stays with you (Gate 3). Job Lander hands you a tailored résumé and the apply link, and stops.

**Q: How is this different from "AI résumé" tools or a single ChatGPT prompt?**
Three ways. (1) It's a **dual-agent system** — a manager orchestrates two specialists (find, then tailor) with a structured handoff, not one prompt doing everything. (2) It has **three human-approval gates**, so judgment stays with the person. (3) **It refuses to fabricate** — when a job needs something your résumé doesn't show, it *asks you* instead of inventing a plausible-sounding lie.

**Q: Won't the tailored résumés be full of made-up experience?**
No. The seeker's résumé is the single source of truth. When a job description asks for something not in it, Agent 2 surfaces a batched clarifying question and only writes what you confirm is real. Gaps you don't close are flagged honestly in the recruiter ranking — never papered over.

**Q: Does it really search LinkedIn? Isn't that against LinkedIn's terms?**
It never scrapes LinkedIn. It uses SerpApi's Google Jobs API, which reads **Google for Jobs** — the aggregation LinkedIn *itself* syndicates postings to. That's the compliant, robust way to reach LinkedIn-sourced roles (with full descriptions) alongside Indeed, Glassdoor, and company sites.

**Q: What does it remember between runs?**
A Google Sheet acts as its memory: every job it analyzes is logged with a status (`seen → approved → tailored → sent`), so it never re-recommends a role and you get an auditable history of your search.

**Q: Is it locked to one person?**
No. Everything person-specific lives in one `profile.json` — résumé path, target titles, locations, work authorization, seniority ceiling, notification email. Swap the profile and Job Lander works for any seeker. A one-time onboarding questionnaire fills it; after that, each run just asks "anything to update?"

**Q: What does it cost to run?**
Free at personal scale: a self-hosted Google Workspace MCP server handles Sheets + Gmail, and SerpApi's free tier covers 100 searches/month. No paid automation platform (Zapier, etc.).

**Q: What's the risk if the job search returns nothing?**
It fails gracefully — it tells you exactly what happened, and you can paste a job link or description directly, so the tailoring half still works end to end.
