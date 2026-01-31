const http = require('http');
const { router } = require('./api/routes');

const PORT = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  router(req, res);
});

server.listen(PORT, () => {
  console.log(`Venture Scout server running on port ${PORT}`);
});

module.exports = { server };
