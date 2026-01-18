const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const controller = require('../controllers/annex.controller');


const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = path.join(__dirname, '../uploads');
    console.log(" Upload destination:", uploadDir);
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const filename = Date.now() + path.extname(file.originalname);
    console.log(" File being saved as:", filename);
    cb(null, filename);
  }
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, 
  fileFilter: (req, file, cb) => {
    console.log(" Checking file:", file.originalname, "Type:", file.mimetype);
    const allowedExtensions = ['jpeg', 'jpg', 'png', 'gif', 'webp'];
    const fileExtension = file.originalname.split('.').pop().toLowerCase();
    const isAllowedExtension = allowedExtensions.includes(fileExtension);
    
    console.log("✓ Extension:", fileExtension, "Allowed:", isAllowedExtension);
    
    if (isAllowedExtension) {
      return cb(null, true);
    } else {
      const error = new Error('Only image files are allowed (jpeg, jpg, png, gif, webp)');
      console.log("wrong", error.message);
      cb(error);
    }
  }
});

router.get('/', controller.getAll);
router.post('/', upload.array('images', 10), controller.create);
router.delete('/', controller.delete);
router.post('/upload', upload.array('images', 10), controller.uploadImages);

// Error handling middleware (must be after all other routes)
router.use((err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    console.error(" Multer error:", err.message);
    return res.status(400).json({ message: `Upload error: ${err.message}` });
  } else if (err) {
    console.error(" General error:", err.message);
    return res.status(400).json({ message: err.message });
  }
  next();
});

module.exports = router;
