# CORS Proxy for MongoDB Atlas

This directory contains a simple CORS proxy server for MongoDB Atlas to be used during local development.

## Setup

1. Install Node.js if you haven't already: https://nodejs.org/

2. Navigate to this directory in your terminal:
   ```
   cd web
   ```

3. Install the required dependencies:
   ```
   npm install
   ```

## Running the Proxy

Start the proxy server with:
```
npm start
```

Or, for development with auto-restart:
```
npm run dev
```

The proxy will start on http://localhost:3001

## Configuration

The proxy is configured to forward requests to MongoDB Atlas. Make sure your MongoDB Atlas IP whitelist includes your local IP address.

## Security Note

This proxy is for development use only. In production, you should:
1. Enable proper CORS on your MongoDB Atlas cluster
2. Use proper authentication and authorization
3. Consider using MongoDB Realm or another backend service for production

## Troubleshooting

- If you get connection errors, make sure:
  - The proxy server is running
  - Your IP is whitelisted in MongoDB Atlas
  - You have a stable internet connection
  - The MongoDB Atlas cluster is running and accessible
