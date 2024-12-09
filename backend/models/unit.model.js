const mongoose = require("mongoose");
const { toJSON, paginate } = require("./plugins");

const unitSchema = mongoose.Schema(
  {
    name: {
      type: String,
    },
    status: {
      type: String,
      enum: [status.enabled, status.disabled],
      default: status.enabled,
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
