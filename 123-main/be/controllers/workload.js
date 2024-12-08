const Workload = require("../models/workload");
const Group = require("../models/group");
const mongoose = require("mongoose");
const { ObjectId } = mongoose.Types;

// Tạo workload (chỉ dành cho người tạo nhóm)
async function CreateWorkload(req, res) {
    const { groupId, listId, content } = req.body;
    const { userId } = res.locals; // Lấy `userId` từ thông tin xác thực

    if (!groupId || !listId || !content) {
        return res.status(400).json({ error: "groupId, listId, and content are required." });
    }

    try {
        // Xác minh groupId hợp lệ
        const group = await Group.findById(groupId).exec();
        if (!group) {
            return res.status(404).json({ error: "group not found." });
        }

        // Xác minh người tạo nhóm
        if (group.createdBy.toString() !== userId.toString()) {
            return res.status(403).json({ error: "Only the group creator can create workloads." });
        }

        // Xác minh listId thuộc group
        if (!group.ListId.includes(listId)) {
            return res.status(400).json({ error: "The provided listId does not belong to this group." });
        }

        // Tạo workload
        const newWorkload = await Workload.create({
            createdBy: new ObjectId(userId),
            groupId: new ObjectId(groupId),
            listId: [new ObjectId(listId)],
            content
        });

        return res.status(201).json(newWorkload);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
}

// Xem chi tiết workload
async function WorkloadDetail(req, res) {
    const { workloadId } = req.params;

    if (!workloadId) {
        return res.status(400).json({ error: "workloadId is required." });
    }

    try {
        const workload = await Workload.findById(workloadId)
            .populate("createdBy", "name email") // Lấy thông tin người tạo
            .populate("groupId", "name")         // Lấy tên nhóm
            .populate("listId", "content")     // Lấy chi tiết danh sách
            .exec();

        if (!workload) {
            return res.status(404).json({ error: "Workload not found." });
        }

        res.status(200).json(workload);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
}

module.exports = {
    CreateWorkload,
    WorkloadDetail
};
