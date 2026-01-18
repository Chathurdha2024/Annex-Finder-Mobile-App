const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ limit: '50mb', extended: true }));


app.use('/uploads', express.static(path.join(__dirname, 'uploads')));


app.use((req, res, next) => {
  console.log(` ${req.method} ${req.path}`);
  next();
});

app.use('/api/annexes', require('./routes/annex.routes'));

module.exports = app;
