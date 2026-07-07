# Install Job Lander into your own Claude

Job Lander runs as a **Claude Code skill**. Setup is one-time (~20–30 min, mostly connecting a free Google MCP + a free job-search key). After that, you just say *"run Job Lander."*

## Prerequisites
- **Claude Code** (desktop app or CLI) — https://claude.com/claude-code
- **Python 3.11+** and **[uv](https://docs.astral.sh/uv/)** (`uv` can also manage Python for you)
- **LibreOffice** (for résumé → PDF) — optional but recommended
- A **Google account** (for the memory Sheet + Gmail delivery)
- A free **[SerpApi](https://serpapi.com)** account (for LinkedIn/Indeed job search)

---

## 1. Install the skill
Copy the `skill/` folder from this repo into your Claude skills directory, renamed to `job-lander`:

- **Claude Code (project):** `.claude/skills/job-lander/`
- so you end up with `.claude/skills/job-lander/SKILL.md`, `.../agents/`, `.../profile.template.json`.

## 2. Connect a Google Workspace MCP (memory + send)
Job Lander uses a self-hosted Google Workspace MCP server for the Google Sheet (memory) and Gmail (delivery).

1. In **Google Cloud Console**, create a project, enable the **Gmail API**, **Google Sheets API**, and **Google Drive API**.
2. Configure the **OAuth consent screen** (External, Testing) and add your Google address as a **Test user**.
3. Create an **OAuth client** (Desktop app) → note the **Client ID** and **Client Secret**.
4. Add the server to your Claude desktop config (`claude_desktop_config.json`):
   ```json
   {
     "mcpServers": {
       "google-workspace": {
         "command": "cmd",
         "args": ["/c", "uvx", "workspace-mcp", "--transport", "stdio", "--single-user", "--tools", "gmail", "sheets", "drive"],
         "env": {
           "GOOGLE_OAUTH_CLIENT_ID": "YOUR_CLIENT_ID",
           "GOOGLE_OAUTH_CLIENT_SECRET": "YOUR_CLIENT_SECRET"
         }
       }
     }
   }
   ```
   > **Windows note:** the `cmd /c` wrapper avoids PATH issues. If `uvx` can't resolve a managed Python, pin it: add `"--python", "C:\\path\\to\\python.exe"` right after `uvx`.
   > **Transport:** `--transport stdio` is required for the desktop app to attach.
5. **Fully restart Claude** (config is read at cold start). On first use, approve the Google sign-in in your browser.
6. Create a Google Sheet named e.g. **"Job Lander Log"** with a header row: `date_seen | title | company | link | fit_score | status`. Note its **spreadsheet ID** (from the URL).

## 3. Add a SerpApi key (job search)
1. Sign up free at **https://serpapi.com** (100 searches/month free).
2. Save your key to the file the skill reads:
   ```bash
   mkdir -p ~/.job-lander && echo "YOUR_SERPAPI_KEY" > ~/.job-lander/serpapi_key.txt
   ```
   (or set the `SERPAPI_API_KEY` environment variable instead).

## 4. Fill your profile
Copy `profile.template.json` → `profile.json` and fill it in (or just run the skill — the first run walks you through an onboarding questionnaire and writes it for you):
- `seeker.resume_path` — absolute path to your standard résumé `.docx`
- `seeker.email`, `seeker.work_authorization`
- `search.target_roles`, `locations`, `work_model`, `seniority_levels`, `recency_days`, `min_salary`
- `memory.spreadsheet_id` — your Job Lander Log sheet ID
- `delivery.notify_email`

## 5. Run it
In Claude, say **"run Job Lander"** (or `/job-lander`). It will:
onboard (first run) → search → show a shortlist (**you approve**) → ask batched questions (**you answer**) → tailor résumés → **email you the packet**. You review and apply.

---

## Troubleshooting
- **"Could not attach to MCP server"** → ensure `--transport stdio`, valid credentials, and a **full cold restart** of Claude.
- **`access_denied` on Google sign-in** → add your email as a **Test user** on the OAuth consent screen, and confirm the OAuth client is in the **same project** whose APIs you enabled.
- **Gmail attachment fails** → the send tool only reads files in its permitted dir (`~/.workspace-mcp/attachments`); copy the résumé there before attaching, or pass base64 content.
- **SerpApi 404 on `/search`** → make sure you're using **SerpApi** (not JSearch's free tier, which gates search), with a valid key.
- **No PDF** → install LibreOffice; the skill converts `.docx` → PDF via headless `soffice`.
