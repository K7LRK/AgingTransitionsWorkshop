# Shared Team Standards — Aging Transitions Workshop

These standards apply to all team members. Every team member CLAUDE.md inherits from this file by virtue of being in the `Team/` directory.

---

## Clark Johnson — Principal Investigator

Clark Johnson is the PI and project organizer. All work product is produced for his use. Final decisions on direction, framing, and content are always his. Team members advise, draft, and analyze — they do not decide.

**Before your first task, read `~/Scholarship/ProjectStarter/ClarksWorkingStyle.md`** — his background, intellectual engagement style, pacing preferences, and standing document conventions. It's referenced from every project, not just this one.

---

## Tone and Response Style

- Be direct and concise. Short sentences preferred. No filler words or preamble.
- Do not restate what you have been asked before answering. Lead with the answer or the work.
- Do not add features, refactor, or make improvements beyond what was asked.
- No emojis unless Clark explicitly requests them.
- When referencing specific content, include the file path so Clark can navigate directly.

---

## Date and Time

All documents must include `**Date:** YYYY-MM-DD HH:MM` in the header. Run:

```
TZ='America/Phoenix' date '+%Y-%m-%d %H:%M'
```

Never guess the date. Clark is in Tucson, AZ (UTC−7, no daylight saving time observed). The workshop is on Lopez Island, WA — note that Lopez Island observes Pacific time, which may differ from Tucson time for scheduling purposes.

---

## Language

Use American English spellings throughout all documents (e.g., "color" not "colour", "organize" not "organise").

---

## Document Header Format

Every document you produce should open with a header block:

```
**Prepared by:** [Team Member Name]
**Date:** YYYY-MM-DD HH:MM
**For:** Clark Johnson (PI), via Martha
**Status:** [In progress / Reviewed / Accepted / Final / Pending incorporation / Superseded / Withdrawn]
**Re:** [Brief description of document purpose]
```

---

## Context Paragraph

Every `.md` file that goes to the Outbox must open with a `## Context` section (before the document header) explaining:
- What prompted this document
- What session it was produced in
- How it connects to the broader project

---

## Outbox Workflow

Completed deliverables are placed in `Outbox/` with a timestamped filename: `YYMMDDHHMM_DocumentName.docx`. The timestamp is Tucson local time. Martha coordinates export timing.

---

## Status Vocabulary

| Status | Meaning |
|--------|---------|
| `In progress` | Not yet complete or processed |
| `Reviewed` | Clark has read it; done |
| `Accepted` | Approved current state; remains a living document |
| `Final` | No further revision |
| `Pending incorporation` | Read; partially acted on; continues to guide work |
| `Superseded` | Replaced by newer version; no longer active |
| `Withdrawn` | Set aside for possible future use; no further action |

---

## Restricted Folders

- `CJ/` — Clark's personal folder. Never read, reference, or write to it.
- `WorkingPapers/` — Clark's own conceptual memos written for team use. Always read relevant files here before beginning a task.
