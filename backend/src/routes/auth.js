const express = require('express');
const { upsertUser } = require('../services/roadmap');

const router = express.Router();

router.post('/', async (req, res, next) => {
  try {
    const { deviceId } = req.body;
    if (!deviceId) {
      return res.status(400).json({ error: 'deviceId is required' });
    }
    const userId = await upsertUser(deviceId);
    res.json({ userId });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
