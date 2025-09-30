const http = require('http');
const url = require('url');

const PORT = 8001;

const server = http.createServer((req, res) => {
  const { pathname } = url.parse(req.url, true);

  if (req.method === 'GET' && pathname === '/api/hello') {
    const data = { message: 'приветули!!' };
    res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' });
    return res.end(JSON.stringify(data));
  }

  res.writeHead(404, { 'Content-Type': 'application/json; charset=utf-8' });
  res.end(JSON.stringify({ error: 'Not Found' }));
});

server.listen(PORT, '127.0.0.1', () => {
  console.log(`Project1 Node server listening on http://127.0.0.1:${PORT}`);
});