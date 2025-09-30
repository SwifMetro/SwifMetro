const WebSocket = require('ws');

console.log('🚀 SWIFMETRO NODE SERVER');
console.log('📡 Starting on port 8081...');

const wss = new WebSocket.Server({ port: 8081 });

wss.on('connection', function connection(ws) {
  console.log('🔥🔥🔥 IPHONE CONNECTED!!!');
  
  ws.on('message', function incoming(message) {
    console.log('📱 FROM IPHONE:', message.toString());
  });
  
  ws.on('error', (err) => {
    console.log('❌ Error:', err);
  });
  
  ws.send('Welcome to SwifMetro!');
});

console.log('⏳ Waiting for iPhone...');