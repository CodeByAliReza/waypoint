require('dotenv').config();

const express = require('express');
const cors = require('cors');
const cron = require('node-cron');
const migrate = require('./db/migrate');
const authRoutes = require('./routes/auth');
const roadmapRoutes = require('./routes/roadmap');
const stageRoutes = require('./routes/stage');
const errorHandler = require('./middleware/errorHandler');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.use('/auth', authRoutes);
app.use('/roadmap', roadmapRoutes);
app.use('/roadmap', stageRoutes);

app.use(errorHandler);

// Weekly nudge cron — every Monday at 9am UTC
cron.schedule('0 9 * * 1', () => {
  console.log('[CRON] Weekly nudge: check incomplete stages and notify users');
  // TODO: Integrate FCM push notifications here
});

async function start() {
  try {
    await migrate();
    app.listen(PORT, () => {
      console.log(`Waypoint API running on port ${PORT}`);
    });
  } catch (err) {
    console.error('Failed to start server:', err);
    process.exit(1);
  }
}

start();
