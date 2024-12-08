const { Schema, model } = require("mongoose");
const { ObjectId } = Schema.Types; 
const User = require('./user');
const Group = require('./group');

const workloadSchema = new Schema({
    createdBy: {
        type: ObjectId,
        ref: User,
        required: true
    },
    groupId: {
        type: ObjectId,
        ref: Group,
    },
    listId:{
        type: [ObjectId]
    },
    content: {
        type: String,
        required: true
    }
},

{ timestamps: true }
)

const Workload = model("Workload", workloadSchema);
module.exports = Workload;
