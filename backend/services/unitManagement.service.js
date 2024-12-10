const { UnitModel } = require("../models");
const { status } = require("../utils/constant");

const getAllUnits = async () => {
  // TODO: cache
  const units = await UnitModel.find({
    status: { $ne: status.disabled },
  });
  return units;
};

const createUnit = async (createBody) => {
  const unit = await UnitModel.create(createBody);
  return unit;
};

const updateUnitById = async ({ unitId, updateBody }) => {
  const updatedUnit = await UnitModel.findByIdAndUpdate(
    unitId,
    { $set: updateBody },
    { new: true }
  );
  return updatedUnit;
};

const deleteUnitById = async (unitId) => {
  await UnitModel.findByIdAndUpdate(unitId, {
    $set: { status: status.disabled },
  });
};

module.exports = {
  getAllUnits,
  createUnit,
  updateUnitById,
  deleteUnitById,
};
