const { Schema, model } = require("mongoose");
const { ObjectId } = Schema.Types; 
const User = require('./user');
const Group = require('./group');
const Workload = require('./workload');

const listSchema = new Schema({
    userId: {
        type: ObjectId,
        ref: User,
        required: true
    },
    groupId: {
        type: ObjectId,
        ref: Group,
    },
    content: {
        type: String,
    },
    workloadId: {
        type: ObjectId,
        ref: Workload,
    }
}, { timestamps: true });  // Bật timestamps

const List = model("List", listSchema);
module.exports = List;
