const _ = require("lodash");
const catchAsync = require("../utils/catchAsync");
const unitManagementService = require("../services/unitManagement.service");
const { throwBadRequest } = require("../utils/badRequestHandlingUtils");
const { roleMap } = require("../utils/roles");

const getAllUnits = catchAsync(async (req, res) => {
  throwBadRequest(_.get(req, "user.role") !== roleMap.admin, "Forbidden!");
  const units = await unitManagementService.getAllUnits();
  res.status(200).send(units);
});

const createUnit = catchAsync(async (req, res) => {
  throwBadRequest(_.get(req, "user.role") !== roleMap.admin, "Forbidden!");
  const createBody = req.body;
  await unitManagementService.createUnit(createBody);
  res.sendStatus(201);
});

const updateUnitById = catchAsync(async (req, res) => {
  throwBadRequest(_.get(req, "user.role") !== roleMap.admin, "Forbidden!");
  const { unitId } = req.params;
  const updateBody = req.body;
  await unitManagementService.updateUnitById({ updateBody, unitId });
  res.sendStatus(200);
});

const deleteUnitById = catchAsync(async (req, res) => {
  throwBadRequest(_.get(req, "user.role") !== roleMap.admin, "Forbidden!");
  const { unitId } = req.params;
  await unitManagementService.deleteUnitById(unitId);
  res.sendStatus(200);
});

module.exports = {
  getAllUnits,
  createUnit,
  updateUnitById,
  deleteUnitById,
};
