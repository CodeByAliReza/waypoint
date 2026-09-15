function errorHandler(err, req, res, _next) {
  console.error('Error:', err.message);

  if (err.message.includes('validation failed')) {
    return res.status(422).json({ error: err.message });
  }

  if (err.message.includes('LLM API error')) {
    return res.status(502).json({ error: 'Failed to generate roadmap from LLM' });
  }

  if (err.message.includes('Missing required fields')) {
    return res.status(400).json({ error: err.message });
  }

  res.status(500).json({ error: 'Internal server error' });
}

module.exports = errorHandler;
