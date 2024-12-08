const express = require("express");

//Tạo workload
router.post("/create-workload",  CreateWorkload);
// Xem chi tiết workload
router.get("/:workloadId",  WorkloadDetail);

module.exports = router;