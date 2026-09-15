# Waypoint — Project Rules for Agent

## What this app is
Waypoint takes one user ambition and turns it into a short, linear roadmap.
The core value is *reduction of choice*, not breadth of content. Every
architectural or feature decision must protect that constraint.

## Hard constraints (do not violate without explicit human approval)
- Each roadmap stage has **exactly 3 resources**. Never more, never fewer.
- A user has **one active roadmap at a time**. No multi-goal dashboards.
- No social features, no gamification (badges/streaks/leaderboards), no
  infinite content feeds. If a prompt seems to ask for one of these,
  flag it back instead of building it.
- Keep the schema to 3 tables: `users`, `roadmaps`, `stages`. Don't add
  tables preemptively "for future features."

## Stack
- Frontend: Flutter (mobile + web build). Prefer StatefulWidgets over
  adding a state-management package unless complexity genuinely requires it.
- Backend: Node.js + Express, REST (not GraphQL), Postgres.
- LLM calls: used only for roadmap generation. Must return strict JSON
  matching the schema below — validate with Zod, fail loudly on
  malformed output rather than passing it through.
- Auth: email OTP or anonymous device ID for v1. No OAuth/SSO in v1.
- Deploy target: Railway or Render (backend + managed Postgres),
  `flutter build web` for the fastest public demo path.

## API surface (do not expand without updating this file)
- `POST /roadmap` — { ambition, level, hoursPerWeek } → generates + saves roadmap
- `GET /roadmap/:userId` — fetch active roadmap
- `PATCH /roadmap/:id/stage/:stageId` — mark stage complete
- `POST /auth` — OTP or device-based session

## Data model
```
users(id, email_or_device_id, created_at)
roadmaps(id, user_id, ambition, level, hours_per_week, created_at)
stages(id, roadmap_id, order, title, resources jsonb[3], completed bool)
```

## Roadmap generation contract (LLM output shape)
```json
{
  "stages": [
    { "title": "string", "resources": ["string", "string", "string"] }
  ]
}
```
5–8 stages expected. Reject/retry on any stage with resources.length != 3.

## Working conventions
- Use Plan mode for anything touching more than one file; review before
  switching to Build mode.
- Tests live alongside source (`*.test.js` for backend, `*_test.dart`
  for frontend).
- Before adding any new feature, check it against "Hard constraints"
  above. If it conflicts, stop and ask rather than building it.
