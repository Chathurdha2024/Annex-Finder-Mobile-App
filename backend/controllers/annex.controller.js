const Annex = require('../models/annex');
const { v4: uuidv4 } = require('uuid');
const fs = require('fs');
const path = require('path');


exports.getAll = async (req, res) => {
  const annexes = await Annex.find();
  res.json(annexes);
};

exports.create = async (req, res) => {
  try {
    console.log(" Received POST request");
    console.log(" All body fields:", JSON.stringify(req.body));
    console.log(" Files count:", req.files ? req.files.length : 0);
    
    if (req.files && req.files.length > 0) {
      console.log(" File details:", req.files.map(f => ({name: f.filename, path: f.path, size: f.size})));
    }
    
    const { title, location, price, rooms, description, contactNumber, nicNumber } = req.body;
    
    if (!title || !location || !price || !rooms || !description || !contactNumber || !nicNumber) {
      console.log("Missing required fields. Received:", { title, location, price, rooms, description, contactNumber, nicNumber });
      return res.status(400).json({ 
        message: "Missing required fields", 
        received: { title, location, price, rooms, description, contactNumber, nicNumber }
      });
    }
    
    const imageUrls = req.files ? req.files.map(file => `/uploads/${file.filename}`) : [];
    
    console.log(" Image URLs:", imageUrls);
    
    let facilities = req.body.facilities;
    if (typeof facilities === 'string') {
      try {
        facilities = JSON.parse(facilities);
      } catch (e) {
        facilities = [];
      }
    }
    
    const annexData = {
      id: uuidv4(),
      title: req.body.title,
      location: req.body.location,
      price: Number(req.body.price),
      rooms: Number(req.body.rooms),
      description: req.body.description,
      contactNumber: req.body.contactNumber,
      facilities: facilities || [],
      nicNumber: req.body.nicNumber,
      datePosted: new Date(),
      images: imageUrls
    };
    
    console.log("Saving annex to DB:", JSON.stringify(annexData, null, 2));
    
    const annex = new Annex(annexData);
    const savedAnnex = await annex.save();
    
    console.log("Annex saved successfully, ID:", savedAnnex._id);
    
    res.status(201).json(savedAnnex);
  } catch (error) {
    console.error(" Error creating annex:", error.message);
    console.error(" Full error:", error);
    res.status(400).json({ message: error.message, stack: error.stack });
  }
};

exports.uploadImages = async (req, res) => {
  try {
    const { id } = req.body;
    if (!id) {
      return res.status(400).json({ message: "Annex ID is required" });
    }

    const annex = await Annex.findOne({ id });
    if (!annex) {
     
      req.files.forEach(file => {
        fs.unlink(path.join(__dirname, '../uploads', file.filename), (err) => {});
      });
      return res.status(404).json({ message: "Annex not found" });
    }

    const newImageUrls = req.files.map(file => `/uploads/${file.filename}`);
    annex.images = [...(annex.images || []), ...newImageUrls];
    
    await annex.save();
    res.json(annex);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};


exports.delete = async (req, res) => {
  try {
    const { id, nicNumber } = req.body;

    const annex = await Annex.findOne({ id });
    if (!annex || annex.nicNumber !== nicNumber) {
      return res.status(403).json({ message: "Wrong NIC number" });
    }

    
    if (annex.images && annex.images.length > 0) {
      annex.images.forEach(imageUrl => {
        const filename = imageUrl.split('/').pop();
        fs.unlink(path.join(__dirname, '../uploads', filename), (err) => {});
      });
    }

    await annex.deleteOne();
    res.json({ message: "Deleted successfully" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};
