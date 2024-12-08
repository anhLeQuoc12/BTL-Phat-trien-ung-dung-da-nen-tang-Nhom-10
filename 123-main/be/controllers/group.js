const Group = require("../models/group");
const mongoose = require("mongoose");
const { ObjectId } = mongoose.Types;


// Tạo group mới
async function createGroup(req, res) {
    const { createdBy, name, member } = req.body;

    if (!createdBy || !name) {
        return res.status(400).json({ error: "createdBy and name are required." });
    }

    try {
        // Đảm bảo rằng createdBy luôn có mặt trong mảng member
        const allMembers = member ? [...member, createdBy] : [createdBy];

        // Tạo group mới với các thành viên đã bao gồm createdBy
        const newGroup = await Group.create({
            createdBy: new ObjectId(createdBy),
            name,
            member: allMembers.map(id => new ObjectId(id)), // Chuyển tất cả thành viên thành ObjectId
            ListId: [] // Nếu có trường ListId cần thiết
        });

        return res.status(201).json(newGroup);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
}

// Xem danh sách các danh sách mua sắm trong group
async function getShoppingList(req, res) {
    const { groupId } = req.query;

    if (!groupId) {
        return res.status(400).json({ error: "groupId is required." });
    }

    try {
        const group = await Group.findById(groupId).populate("ListId").exec();

        if (!group) {
            return res.status(404).json({ error: "group not found." });
        }

        res.status(200).json(group.ListId);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
}

// Chia sẻ danh sách mua sắm theo groupId
async function getListByGroupId(req, res) {
    const { groupId } = req.query;

    if (!groupId) {
        return res.status(400).json({ error: "groupId is required." });
    }

    try {
        const group = await Group.findById(groupId)
            .populate("member", "name email") // Populate thông tin thành viên
            .populate("ListId", "content")   // Populate thông tin danh sách
            .exec();

        if (!group) {
            return res.status(404).json({ error: "group not found." });
        }

        res.status(200).json({
            groupName: group.name,
            members: group.member,
            lists: group.ListId
        });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
}

module.exports = {
    createGroup,
    getShoppingList,
    getListByGroupId
};
