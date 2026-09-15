function authMiddleware(req, res, next) {
  const deviceId = req.headers['x-device-id'];
  if (!deviceId) {
    return res.status(401).json({ error: 'Missing x-device-id header' });
  }
  req.deviceId = deviceId;
  next();
}

module.exports = authMiddleware;
