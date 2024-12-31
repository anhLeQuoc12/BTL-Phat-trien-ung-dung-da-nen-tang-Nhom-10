const express = require("express");
const userManagementController = require("../controllers/userManagement.controller");
const userGroupManagementController = require("../controllers/userGroupManagement.controller");
const categoryManagementController = require("../controllers/categoryManagement.controller");
const unitManagementController = require("../controllers/unitManagement.controller");
const auth = require("../middlewares/auth");
const checkIsAdminOrNotMiddleware = require("../middlewares/check-admin");
const { createFood, getAllFoods, getFoodById, updateFoodById, deleteFoodById } = require("../controllers/food");

const router = express.Router();
router.route('/user-management/query').post(auth, checkIsAdminOrNotMiddleware, userManagementController.queryUser);
router.route('/user/:userId').get(auth, checkIsAdminOrNotMiddleware, userManagementController.getUserById);
router.route('/user/:userId').patch(auth, checkIsAdminOrNotMiddleware, userManagementController.updateUserById);
router.route('/user/:userId').delete(auth, checkIsAdminOrNotMiddleware, userManagementController.deleteUserById);

router.route('/group/:userGroupId').get(auth, checkIsAdminOrNotMiddleware, userGroupManagementController.getUserGroupById);
router.route('/group/').post(auth, checkIsAdminOrNotMiddleware, userGroupManagementController.createUserGroup);
router.route('/group/:userGroupId').patch(auth, checkIsAdminOrNotMiddleware, userGroupManagementController.updateUserGroupById);
router.route('/group/:userGroupId').delete(auth, checkIsAdminOrNotMiddleware, userGroupManagementController.deleteUserGroupById);

router.route('/category/').get(auth, checkIsAdminOrNotMiddleware, categoryManagementController.getAllCategories);
router.route('/category/').post(auth, checkIsAdminOrNotMiddleware, categoryManagementController.createCategory);
router.route('/category/:categoryId').patch(auth, checkIsAdminOrNotMiddleware, categoryManagementController.updateCategoryById);
router.route('/category/:categoryId').delete(auth, checkIsAdminOrNotMiddleware, categoryManagementController.deleteCategoryById);

router.route('/unit/').get(auth, checkIsAdminOrNotMiddleware, unitManagementController.getAllUnits);
router.route('/unit/').post(auth, checkIsAdminOrNotMiddleware, unitManagementController.createUnit);
router.route('/unit/:unitId').patch(auth, checkIsAdminOrNotMiddleware, unitManagementController.updateUnitById);
router.route('/unit/:unitId').delete(auth, checkIsAdminOrNotMiddleware, unitManagementController.deleteUnitById);

router.post("/food", auth, checkIsAdminOrNotMiddleware, createFood);
router.get("/food", auth, checkIsAdminOrNotMiddleware, getAllFoods);
router.get("/food/:id", auth, checkIsAdminOrNotMiddleware, getFoodById);
router.put("/food/:id", auth, checkIsAdminOrNotMiddleware, updateFoodById);
router.delete("/food/:id", auth, checkIsAdminOrNotMiddleware, deleteFoodById);

module.exports = router;
