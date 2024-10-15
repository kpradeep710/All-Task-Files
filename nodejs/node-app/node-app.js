const http = require('http');

// Create an HTTP server
const server = http.createServer((req, res) => {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain');
    res.end('Hello, World!\n');
});

// Define the port number
const port = 3000;
server.listen(port, () => {
    console.log(`Server running at http://localhost:${port}/`);
});
