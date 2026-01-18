require('dotenv').config();
const fs = require('fs');
const path = require('path');
const connectDB = require('./config/db');
const app = require('./app');

// Ensure uploads directory exists
const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
  console.log(" Created uploads directory:", uploadsDir);
}

connectDB();

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Backend running on http://localhost:${3000}`);
});
