const mongoose = require("mongoose");
const { toJSON, paginate } = require("../../models/plugins");

const userGroupSchema = mongoose.Schema(
  {
    name: {
      type: String,
    },
    users: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
      },
    ],
  },
  {
    timestamps: true,
  }
);

// add plugin that converts mongoose to json
userGroupSchema.plugin(toJSON);
userGroupSchema.plugin(paginate);

const UserGroup = mongoose.model("userGroup", userGroupSchema);

module.exports = UserGroup;
