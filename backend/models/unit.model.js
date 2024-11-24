const mongoose = require("mongoose");
const { toJSON, paginate } = require("../../models/plugins");

const unitSchema = mongoose.Schema(
  {
    name: {
      type: String,
    },
  },
  {
    timestamps: true,
  }
);

// add plugin that converts mongoose to json
unitSchema.plugin(toJSON);
unitSchema.plugin(paginate);

const Unit = mongoose.model("unit", unitSchema);

module.exports = Unit;
