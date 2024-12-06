const mongoose = require("mongoose");
const { toJSON, paginate } = require("./plugins");
const { status } = require("../utils/constant");

const categorySchema = mongoose.Schema(
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
categorySchema.plugin(toJSON);
categorySchema.plugin(paginate);

const Category = mongoose.model("category", categorySchema);

module.exports = Category;
