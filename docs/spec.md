# Waypoint — API & Data Spec

## Data Model

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE roadmaps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  ambition TEXT NOT NULL,
  level TEXT NOT NULL,
  hours_per_week INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE stages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  roadmap_id UUID REFERENCES roadmaps(id) ON DELETE CASCADE,
  "order" INTEGER NOT NULL,
  title TEXT NOT NULL,
  resources JSONB NOT NULL,
  completed BOOLEAN DEFAULT false
);
```

## API Endpoints

### POST /auth
Create or retrieve a user by device ID.
```
Request:  { "deviceId": "string" }
Response: { "userId": "uuid" }
```

### POST /roadmap
Generate a new roadmap from an ambition. Calls LLM, validates output, saves to DB.
```
Request:  { "userId": "uuid", "ambition": "string", "level": "string", "hoursPerWeek": number }
Response: {
  "id": "uuid",
  "ambition": "string",
  "level": "string",
  "hoursPerWeek": number,
  "createdAt": "iso",
  "stages": [
    {
      "id": "uuid",
      "order": number,
      "title": "string",
      "resources": ["string", "string", "string"],
      "completed": false
    }
  ]
}
```

### GET /roadmap/:userId
Fetch the latest active roadmap for a user.
```
Response: Same shape as POST /roadmap response, or 404 if none exists.
```

### PATCH /roadmap/:id/stage/:stageId
Mark a stage as complete.
```
Request:  { "completed": true }
Response: Updated stage object.
```

## LLM Output Contract

The LLM must return strict JSON matching:
```json
{
  "stages": [
    { "title": "string", "resources": ["string", "string", "string"] }
  ]
}
```

- 5–8 stages expected.
- Each stage must have exactly 3 resources.
- Reject/retry on any violation.

## Constraints
- Each roadmap stage has exactly 3 resources. Never more, never fewer.
- A user has one active roadmap at a time.
- No social features, no gamification, no infinite content feeds.
- Schema is exactly 3 tables: users, roadmaps, stages.
