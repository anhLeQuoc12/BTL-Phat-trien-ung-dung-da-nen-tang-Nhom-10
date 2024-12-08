const mongoose = require("mongoose");
// const { toJSON, paginate } = require("../../models/plugins");
// const { MIN_PASSWORD_LENGTH, status } = require("../utils/constant");
// const { roles } = require("../utils/roles");

const userSchema = mongoose.Schema(
  {
    name: {
      type: String,
      trim: true,
    },
    phone: {
      type: String,
      trim: true,
    },
    email: {
      type: String,
      trim: true,
    },
    groupId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "UserGroup",
    },
    password: {
      type: String,
      trim: true,
      // minlength: MIN_PASSWORD_LENGTH,
      private: true, // used by the toJSON plugin
    },
    // role: {
    //   type: String,
    //   enum: roles,
    //   default: "user",
    // },
    status: {
      type: String,
      required: true,
      // enum: [status.enabled, status.disabled],
      // default: status.enabled,
    },
  },
  {
    timestamps: true,
  }
);

// add plugin that converts mongoose to json
// userSchema.plugin(toJSON);
// userSchema.plugin(paginate);

const User = mongoose.model("user", userSchema);

module.exports = User;