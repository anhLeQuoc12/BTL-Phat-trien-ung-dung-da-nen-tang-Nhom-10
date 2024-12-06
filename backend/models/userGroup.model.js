const mongoose = require("mongoose");
const { toJSON, paginate } = require("../../models/plugins");
const { status } = require("../utils/constant");

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
userGroupSchema.plugin(toJSON);
userGroupSchema.plugin(paginate);

const UserGroup = mongoose.model("userGroup", userGroupSchema);

module.exports = UserGroup;
