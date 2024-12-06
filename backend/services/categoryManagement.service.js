const { CategoryModel } = require("../models");
const { status } = require("../utils/constant");

const getAllCategories = async () => {
  // TODO: cache
  const categories = await CategoryModel.find({
    status: { $ne: status.disabled },
  });
  return categories;
};

const createCategory = async (createBody) => {
  await CategoryModel.create(createBody);
};

const updateCategoryById = async ({ updateBody, categoryId }) => {
  const updatedCategory = await CategoryModel.findByIdAndUpdate(
    categoryId,
    { $set: updateBody },
    { new: true }
  );
  return updatedCategory;
};

const deleteCategoryById = async (categoryId) => {
  await CategoryModel.findByIdAndUpdate(categoryId, {
    $set: { status: status.disabled },
  });
};

module.exports = {
  getAllCategories,
  createCategory,
  updateCategoryById,
  deleteCategoryById,
};
