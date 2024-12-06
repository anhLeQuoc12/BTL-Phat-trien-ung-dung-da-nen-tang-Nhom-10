const express = require("express");
const userManagementController = require("../controllers/userManagement.controller");
const userGroupManagementController = require("../controllers/userGroupManagement.controller");
const categoryManagementController = require("../controllers/categoryManagement.controller");
const unitManagementController = require("../controllers/unitManagement.controller");
const auth = require("../middlewares/auth");

const router = express.Router();
router.route('/user-management/query').post(auth(), userManagementController.queryUser);
router.route('/user/:userId').get(auth(), userManagementController.getUserById);
router.route('/user/:userId').patch(auth(), userManagementController.updateUserById);
router.route('/user/:userId').delete(auth(), userManagementController.deleteUserById);

router.route('/group/:userGroupId').get(auth(), userGroupManagementController.getUserGroupById);
router.route('/group/').post(auth(), userGroupManagementController.createUserGroup);
router.route('/group/:userGroupId').patch(auth(), userGroupManagementController.updateUserGroupById);
router.route('/group/:userGroupId').delete(auth(), userGroupManagementController.deleteUserGroupById);

router.route('/category/').get(auth(), categoryManagementController.getAllCategories);
router.route('/category/').post(auth(), categoryManagementController.createCategory);
router.route('/category/:categoryId').patch(auth(), categoryManagementController.updateCategoryById);
router.route('/category/:categoryId').delete(auth(), categoryManagementController.deleteCategoryById);

router.route('/unit/').get(auth(), unitManagementController.getAllUnits);
router.route('/unit/').post(auth(), unitManagementController.createUnit);
router.route('/unit/:unitId').patch(auth(), unitManagementController.updateUnitById);
router.route('/unit/:unitId').delete(auth(), unitManagementController.deleteUnitById);

module.exports = router;
