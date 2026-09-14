const express = require('express');
const { markStageComplete } = require('../services/roadmap');

const router = express.Router();

router.patch('/:id/stage/:stageId', async (req, res, next) => {
  try {
    const { id, stageId } = req.params;
    const { completed } = req.body;

    if (typeof completed !== 'boolean') {
      return res.status(400).json({ error: 'completed must be a boolean' });
    }

    const stage = await markStageComplete(id, stageId, completed);
    if (!stage) {
      return res.status(404).json({ error: 'Stage not found' });
    }
    res.json(stage);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
