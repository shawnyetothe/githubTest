const { getStartups, getStartupById } = require('./controllers/startups');
const { getDeals, createDeal } = require('./controllers/deals');

function router(req, res) {
  const { method, url } = req;

  // Set JSON content type
  res.setHeader('Content-Type', 'application/json');

  // API Routes
  if (url === '/api/health' && method === 'GET') {
    res.statusCode = 200;
    return res.end(JSON.stringify({ status: 'ok', service: 'venture-scout' }));
  }

  if (url === '/api/startups' && method === 'GET') {
    return getStartups(req, res);
  }

  if (url.match(/^\/api\/startups\/\w+$/) && method === 'GET') {
    return getStartupById(req, res);
  }

  if (url === '/api/deals' && method === 'GET') {
    return getDeals(req, res);
  }

  if (url === '/api/deals' && method === 'POST') {
    return createDeal(req, res);
  }

  // 404 Not Found
  res.statusCode = 404;
  res.end(JSON.stringify({ error: 'Not Found' }));
}

module.exports = { router };
