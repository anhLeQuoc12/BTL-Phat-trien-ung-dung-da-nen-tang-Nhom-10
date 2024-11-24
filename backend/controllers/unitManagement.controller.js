const catchAsync = require("../utils/catchAsync");
const unitManagementService = require("../services/unitManagement.service");

const getAllUnits = catchAsync(async (req, res) => {
  const units = await unitManagementService.getAllUnits();
  res.status(200).send(units);
});

const createUnit = catchAsync(async (req, res) => {
  const createBody = req.body;
  await unitManagementService.createUnit(createBody);
  res.status(201);
});

const updateUnitById = catchAsync(async (req, res) => {
  const { unitId } = req.params;
  const updateBody = req.body;
  await unitManagementService.updateUnitById({ ...updateBody, unitId });
  res.status(200);
});

const deleteUnitById = catchAsync(async (req, res) => {
  const { unitId } = req.params;
  await unitManagementService.deleteUnitById(unitId);
  res.status(200);
});

module.exports = {
  getAllUnits,
  createUnit,
  updateUnitById,
  deleteUnitById,
};
