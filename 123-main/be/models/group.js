const { Schema, model } = require("mongoose");
const { ObjectId } = Schema.Types; 
const User = require('./user');

const groupSchema = new Schema({
    createdBy: {
        type: ObjectId,
        ref: User,
        required: true
    },
    name: {
        type: String,
        required: true
    },
    member:{
        type: [ObjectId],
        ref: User,
    },
    ListId:{
        type: [ObjectId]
    },
},

{ timestamps: true }
)

const Group = model("groups", groupSchema);
module.exports = Group;
