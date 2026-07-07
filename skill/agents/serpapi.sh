#!/usr/bin/env bash
# SerpApi Google Jobs — the broadest source: LinkedIn + Indeed + Glassdoor + ZipRecruiter +
# company sites, all via Google for Jobs. Returns FULL job descriptions in one call.
# Free tier: 100 searches/month.
#
# Setup (one-time):
#   1. Free account + API key: https://serpapi.com  (Dashboard shows your key)
#   2. Save it:  echo "YOUR_SERPAPI_KEY" > ~/.job-lander/serpapi_key.txt
#      (or export SERPAPI_API_KEY=...)
#
# Usage:  ./serpapi.sh "Product Manager in Seattle, WA" 3days
#   arg1 = query (role + location)   arg2 = date filter: today|3days|week|month  (default: week; "" = any)

set -euo pipefail
KEY="${SERPAPI_API_KEY:-$(cat "$HOME/.job-lander/serpapi_key.txt" 2>/dev/null || true)}"
KEY="$(printf '%s' "$KEY" | tr -d '[:space:]')"  # strip stray spaces/newlines
if [ -z "$KEY" ]; then
  echo '{"error":"No SerpApi key. See setup in serpapi.sh header."}' >&2
  exit 1
fi
QUERY="${1:?usage: serpapi.sh \"<role> in <location>\" [today|3days|week|month]}"
DATE="${2:-week}"

ARGS=(--data-urlencode "engine=google_jobs"
      --data-urlencode "q=${QUERY}"
      --data-urlencode "hl=en"
      --data-urlencode "gl=us"
      --data-urlencode "api_key=${KEY}")
[ -n "$DATE" ] && ARGS+=(--data-urlencode "chips=date_posted:${DATE}")

curl -s --get "https://serpapi.com/search.json" "${ARGS[@]}"
# Response: .jobs_results[] with title, company_name, location, description (FULL text),
#   job_highlights[{title,items[]}] (Qualifications/Responsibilities/Benefits, structured),
#   detected_extensions{posted_at,schedule_type,salary}, apply_options[{title,link}], job_id.
#   apply_options[].title is the source board (LinkedIn / Indeed / Glassdoor / company site).
