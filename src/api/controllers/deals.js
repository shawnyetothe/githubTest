const { DealService } = require('../../services/dealService');

async function getDeals(req, res) {
  try {
    const deals = await DealService.findAll();
    res.statusCode = 200;
    res.end(JSON.stringify({ data: deals }));
  } catch (error) {
    res.statusCode = 500;
    res.end(JSON.stringify({ error: 'Failed to fetch deals' }));
  }
}

async function createDeal(req, res) {
  try {
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
    });

    req.on('end', async () => {
      const dealData = JSON.parse(body);
      const deal = await DealService.create(dealData);
      res.statusCode = 201;
      res.end(JSON.stringify({ data: deal }));
    });
  } catch (error) {
    res.statusCode = 500;
    res.end(JSON.stringify({ error: 'Failed to create deal' }));
  }
}

module.exports = { getDeals, createDeal };
