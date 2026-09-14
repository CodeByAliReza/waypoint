const pool = require('../db/pool');
const { generateRoadmap } = require('./llm');
const { validateRoadmapOutput } = require('../schemas/roadmap');

async function upsertUser(deviceId) {
  const result = await pool.query(
    `INSERT INTO users (device_id) VALUES ($1)
     ON CONFLICT (device_id) DO UPDATE SET device_id = EXCLUDED.device_id
     RETURNING id`,
    [deviceId]
  );
  return result.rows[0].id;
}

async function createRoadmap(userId, ambition, level, hoursPerWeek) {
  // Validate input
  if (!userId || !ambition || !level || !hoursPerWeek) {
    throw new Error('Missing required fields: userId, ambition, level, hoursPerWeek');
  }

  // Delete any existing active roadmap for this user (one active roadmap at a time)
  await pool.query(
    `DELETE FROM roadmaps WHERE user_id = $1`,
    [userId]
  );

  // Call LLM
  const llmOutput = await generateRoadmap(ambition, level, hoursPerWeek);

  // Validate LLM output
  const validation = validateRoadmapOutput(llmOutput);
  if (!validation.valid) {
    throw new Error(`LLM output validation failed: ${validation.errors}`);
  }

  // Save to DB
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const roadmapResult = await client.query(
      `INSERT INTO roadmaps (user_id, ambition, level, hours_per_week)
       VALUES ($1, $2, $3, $4)
       RETURNING id, created_at`,
      [userId, ambition, level, hoursPerWeek]
    );

    const roadmapId = roadmapResult.rows[0].id;
    const createdAt = roadmapResult.rows[0].created_at;

    const stages = [];
    for (let i = 0; i < validation.data.stages.length; i++) {
      const stage = validation.data.stages[i];
      const stageResult = await client.query(
        `INSERT INTO stages (roadmap_id, "order", title, resources)
         VALUES ($1, $2, $3, $4)
         RETURNING id, title, resources, completed`,
        [roadmapId, i + 1, stage.title, JSON.stringify(stage.resources)]
      );
      stages.push({
        id: stageResult.rows[0].id,
        order: i + 1,
        title: stageResult.rows[0].title,
        resources: stageResult.rows[0].resources,
        completed: stageResult.rows[0].completed,
      });
    }

    await client.query('COMMIT');

    return {
      id: roadmapId,
      ambition,
      level,
      hoursPerWeek,
      createdAt,
      stages,
    };
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

async function getRoadmap(userId) {
  const roadmapResult = await pool.query(
    `SELECT id, ambition, level, hours_per_week, created_at
     FROM roadmaps
     WHERE user_id = $1
     ORDER BY created_at DESC
     LIMIT 1`,
    [userId]
  );

  if (roadmapResult.rows.length === 0) {
    return null;
  }

  const roadmap = roadmapResult.rows[0];

  const stagesResult = await pool.query(
    `SELECT id, "order", title, resources, completed
     FROM stages
     WHERE roadmap_id = $1
     ORDER BY "order" ASC`,
    [roadmap.id]
  );

  return {
    id: roadmap.id,
    ambition: roadmap.ambition,
    level: roadmap.level,
    hoursPerWeek: roadmap.hours_per_week,
    createdAt: roadmap.created_at,
    stages: stagesResult.rows.map((s) => ({
      id: s.id,
      order: s.order,
      title: s.title,
      resources: s.resources,
      completed: s.completed,
    })),
  };
}

async function markStageComplete(roadmapId, stageId, completed = true) {
  const result = await pool.query(
    `UPDATE stages SET completed = $1
     WHERE id = $2 AND roadmap_id = $3
     RETURNING id, "order", title, resources, completed`,
    [completed, stageId, roadmapId]
  );

  if (result.rows.length === 0) {
    return null;
  }

  const stage = result.rows[0];
  return {
    id: stage.id,
    order: stage.order,
    title: stage.title,
    resources: stage.resources,
    completed: stage.completed,
  };
}

module.exports = { upsertUser, createRoadmap, getRoadmap, markStageComplete };
