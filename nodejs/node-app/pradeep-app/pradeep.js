const http = require('http');
const server = http.createServer((req, res) => {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain');
    res.end('Hello World\n');
});
server.listen(3000, '172.25.98.108 ', () => {
    console.log('Server running at http://172.25.98.108 :3000/');
});
