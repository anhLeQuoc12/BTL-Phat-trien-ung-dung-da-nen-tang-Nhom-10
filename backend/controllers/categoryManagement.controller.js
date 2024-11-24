const catchAsync = require("../utils/catchAsync");
const categoryManagementService = require("../services/categoryManagement.service");

const getAllCategories = catchAsync(async (req, res) => {
  const categories = await categoryManagementService.getAllCategories();
  res.status(200).send(categories);
});

const createCategory = catchAsync(async (req, res) => {
  const createBody = req.body;
  await categoryManagementService.createCategory(createBody);
  res.status(201);
});

const updateCategoryById = catchAsync(async (req, res) => {
  const { categoryId } = req.params;
  const updateBody = req.body;
  await categoryManagementService.updateCategoryById({ ...updateBody, categoryId });
  res.status(200);
});

const deleteCategoryById = catchAsync(async (req, res) => {
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
