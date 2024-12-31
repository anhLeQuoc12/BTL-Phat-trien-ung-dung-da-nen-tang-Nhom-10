const mongoose = require('mongoose');
const { Fridge, FridgeItem } = require('./models/fridgeItem');

const syncFridgeData = async () => {
  try {
    console.log("Starting synchronization...");

    // Kết nối MongoDB
    await mongoose.connect('mongodb+srv://leanh12082002:K1CCdFacW7XYsdU2@cluster0.mp07x.mongodb.net/PTUDDNT_Ung_dung_di_cho_tien_loi?retryWrites=true&w=majority&appName=Cluster0', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    // Lấy toàn bộ Fridges
    const fridges = await Fridge.find().exec();

    for (const fridge of fridges) {
      console.log(`Checking fridge for userId: ${fridge.userId}`);

      for (const item of fridge.items) {
        // Kiểm tra nếu item không tồn tại trong FridgeItems
        const existingItem = await FridgeItem.findById(item._id).exec();

        if (!existingItem) {
          console.log(`Item with ID ${item._id} not found in FridgeItems. Creating...`);

          // Tạo item mới trong FridgeItems
          await FridgeItem.create({
            _id: item._id,
            userId: fridge.userId,
            food: item.food,
            quantity: item.quantity,
            expirationDate: item.expirationDate,
            storageLocation: item.storageLocation,
            isUsed: item.isUsed || false,
            usedQuantity: item.usedQuantity || 0,
            usedAt: item.usedAt || null,
          });

          console.log(`Item with ID ${item._id} created successfully.`);
        }
      }
    }

    console.log("Synchronization completed successfully.");
  } catch (error) {
    console.error("Error during synchronization:", error);
  } finally {
    // Đóng kết nối MongoDB
    await mongoose.disconnect();
  }
};

syncFridgeData();
