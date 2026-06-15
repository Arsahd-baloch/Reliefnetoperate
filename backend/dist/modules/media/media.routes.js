import { Router } from 'express';
import express from 'express';
import multer from 'multer';
import path from 'node:path';
import { mediaController } from './media.controller.js';
import { authenticate } from '../../middleware/auth.js';
const router = Router();
// Serve locally-saved uploads (fallback when Cloudinary is not configured)
const UPLOADS_DIR = path.resolve(process.cwd(), 'uploads');
router.use('/files', express.static(UPLOADS_DIR));
// Configure multer for memory storage (buffers)
const storage = multer.memoryStorage();
const upload = multer({
    storage,
    limits: {
        fileSize: 5 * 1024 * 1024, // 5MB limit
    },
    fileFilter: (_req, file, cb) => {
        if (file.mimetype.startsWith('image/')) {
            cb(null, true);
        }
        else {
            cb(new Error('Only images are allowed'));
        }
    },
});
/**
 * POST /api/media/upload
 * Securely upload an image to Cloudinary (or local storage if not configured).
 */
router.post('/upload', authenticate, upload.single('image'), (req, res, next) => mediaController.upload(req, res, next));
export default router;
//# sourceMappingURL=media.routes.js.map