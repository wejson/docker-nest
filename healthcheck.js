const http = require('http');

http
    .get('http://localhost:3000/ping', res => {
        console.log(`OK : ${res.statusCode}`);
        process.exit(res.statusCode === 200 ? 0 : 1)
    })
    .on('error', () => {
        console.error('ERROR');
        process.exit(2)
    });
