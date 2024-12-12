const express = require('express');
const authMiddleware = require('../middlewares/auth');
const { createFridgeItem, getAllFridgeItem, getFridgeItemById, updateFridgeItemById, deleteFridgeItemById, markItemUsed } = require('../controllers/fridge.controller');

const router = express.Router();

router.post('', authMiddleware, createFridgeItem);
router.get('', authMiddleware, getAllFridgeItem);
router.get('/:id', authMiddleware, getFridgeItemById);
router.put('/:id', authMiddleware, updateFridgeItemById);
router.delete('/:id', authMiddleware, deleteFridgeItemById);
router.put('/used/:id', authMiddleware, markItemUsed);

module.exports = router;

