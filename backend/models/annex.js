const mongoose = require('mongoose');

const annexSchema = new mongoose.Schema({
  id: { type: String, required: true },
  title: String,
  location: String,
  price: Number,
  rooms: Number,
  description: String,
  contactNumber: String,
  facilities: [String],
  nicNumber: String,
  datePosted: Date,
  images: [{ type: String }], // Array of image URLs/paths
}, { timestamps: true });

module.exports = mongoose.model('Annex', annexSchema);
