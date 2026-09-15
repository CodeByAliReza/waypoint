const express = require('express');
const { createRoadmap, getRoadmap } = require('../services/roadmap');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

router.post('/', authMiddleware, async (req, res, next) => {
  try {
    const { ambition, level, hoursPerWeek } = req.body;
    if (!ambition || !level || !hoursPerWeek) {
      return res.status(400).json({
        error: 'ambition, level, and hoursPerWeek are required',
      });
    }

    const userId = req.headers['x-user-id'];
    if (!userId) {
      return res.status(400).json({ error: 'x-user-id header is required' });
    }

    const roadmap = await createRoadmap(userId, ambition, level, hoursPerWeek);
    res.status(201).json(roadmap);
  } catch (err) {
    next(err);
  }
});

router.get('/:userId', async (req, res, next) => {
  try {
    const { userId } = req.params;
    const roadmap = await getRoadmap(userId);
    if (!roadmap) {
      return res.status(404).json({ error: 'No roadmap found' });
    }
    res.json(roadmap);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
