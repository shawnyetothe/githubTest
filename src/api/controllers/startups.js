const { StartupService } = require('../../services/startupService');

async function getStartups(req, res) {
  try {
    const startups = await StartupService.findAll();
    res.statusCode = 200;
    res.end(JSON.stringify({ data: startups }));
  } catch (error) {
    res.statusCode = 500;
    res.end(JSON.stringify({ error: 'Failed to fetch startups' }));
  }
}

async function getStartupById(req, res) {
  try {
    const id = req.url.split('/').pop();
    const startup = await StartupService.findById(id);

    if (!startup) {
      res.statusCode = 404;
      return res.end(JSON.stringify({ error: 'Startup not found' }));
    }

    res.statusCode = 200;
    res.end(JSON.stringify({ data: startup }));
  } catch (error) {
    res.statusCode = 500;
    res.end(JSON.stringify({ error: 'Failed to fetch startup' }));
  }
}

module.exports = { getStartups, getStartupById };
