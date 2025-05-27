// This is a simple CORS proxy for MongoDB Atlas in development
// In production, you should configure CORS on your MongoDB Atlas cluster

const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');

const app = express();
const PORT = 3001; // Or any available port

// Enable CORS for all routes
app.use(cors());

// Proxy configuration
const apiProxy = createProxyMiddleware({
  target: 'https://kelloggs.8myax.mongodb.net',
  changeOrigin: true,
  pathRewrite: {
    '^/api': '', // Remove /api prefix when forwarding to MongoDB
  },
  onProxyReq: (proxyReq, req, res) => {
    // Add any required headers for MongoDB Atlas
    proxyReq.setHeader('Content-Type', 'application/json');
  },
  logLevel: 'debug',
});

// Apply the proxy to the /api route
app.use('/api', apiProxy);

// Start the proxy server
app.listen(PORT, () => {
  console.log(`CORS proxy server running on http://localhost:${PORT}`);
});
