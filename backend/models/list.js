const { Schema, model } = require("mongoose");
const { ObjectId } = Schema.Types;
const User = require("./user.model.js");
const UserGroup = require("./userGroup.model.js");
const Workload = require("./workload");

const listSchema = new Schema(
  {
    userId: {
      type: ObjectId,
      ref: User,
      required: true,
    },
    groupId: {
      type: ObjectId || null,
      ref: UserGroup,
    },
    content: {
      name: {
        type: String,
      },
      items: {
        type: [String], // Định nghĩa items là một mảng chuỗi
        default: [], // Giá trị mặc định là một mảng rỗng
      },
    },
    workloadId: {
      type: ObjectId || null,
      ref: Workload,
    },
  },
  { timestamps: true }
);

const List = model("List", listSchema);
module.exports = List;
