const mongoose = require("mongoose");
const { toJSON, paginate } = require("../../models/plugins");

const categorySchema = mongoose.Schema(
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
categorySchema.plugin(toJSON);
categorySchema.plugin(paginate);

const Category = mongoose.model("category", categorySchema);

module.exports = Category;
