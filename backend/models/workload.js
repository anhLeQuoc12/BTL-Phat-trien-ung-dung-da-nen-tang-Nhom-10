const { Schema, model } = require("mongoose");
const { ObjectId } = Schema.Types;
const User = require("./user.model.js");
const UserGroup = require("./userGroup.model.js");

const workloadSchema = new Schema(
  {
    createdBy: {
      type: ObjectId,
      ref: User,
      required: true,
    },
    groupId: {
      type: ObjectId,
      ref: UserGroup,
    },
    listId: {
      type: [ObjectId],
    },
    content: {
      type: String,
      required: true,
    },
  },

  { timestamps: true }
);

const Workload = model("Workload", workloadSchema);
module.exports = Workload;
