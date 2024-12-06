const _ = require("lodash");
const catchAsync = require("../utils/catchAsync");
const categoryManagementService = require("../services/categoryManagement.service");
const { throwBadRequest } = require("../utils/badRequestHandlingUtils");
const { roleMap } = require("../utils/roles");

const getAllCategories = catchAsync(async (req, res) => {
  throwBadRequest(_.get(req, "user.role") !== roleMap.admin, "Forbidden!");
  const categories = await categoryManagementService.getAllCategories();
  res.status(200).send(categories);
});

const createCategory = catchAsync(async (req, res) => {
  throwBadRequest(_.get(req, "user.role") !== roleMap.admin, "Forbidden!");
  const createBody = req.body;
  await categoryManagementService.createCategory(createBody);
  res.status(201);
});

const updateCategoryById = catchAsync(async (req, res) => {
  throwBadRequest(_.get(req, "user.role") !== roleMap.admin, "Forbidden!");
  const { categoryId } = req.params;
  const updateBody = req.body;
  await categoryManagementService.updateCategoryById({
    updateBody,
    categoryId,
  });
  res.status(200);
});

const deleteCategoryById = catchAsync(async (req, res) => {
  throwBadRequest(_.get(req, "user.role") !== roleMap.admin, "Forbidden!");
  const { categoryId } = req.params;
  await categoryManagementService.deleteCategoryById(categoryId);
  res.status(200);
});

module.exports = {
  getAllCategories,
  createCategory,
  updateCategoryById,
  deleteCategoryById,
};
