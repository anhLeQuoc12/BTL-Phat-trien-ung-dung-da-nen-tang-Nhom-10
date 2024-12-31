const WeeklyShoppingReport = require("../models/weekly-shopping-report");
const ObjectId = require("mongodb").ObjectId;

async function createWeeklyReport(userId, startDate, endDate) {
    try {
        const lists = await List.find({
            userId: userId
        }).exec();

        let purchasedFoods = [];
        for (const list of lists) {
            if (list.date >= startDate && list.date <= endDate) {

                for (const food of list.foods) {

                    if (food.isPurchased) {
                        let alreadyExisted = false;
                        for (let i = 0; i < purchasedFoods.length; i++) {
                            if (purchasedFoods[i].foodId === food.id) {
                                alreadyExisted = true;
                                purchasedFoods[i].quantity += food.quantity;
                                break;
                            }
                        }
                        if (!alreadyExisted) {
                            purchasedFoods.push({
                                foodId: food.id,
                                quantity: food.quantity
                            })
                        }
                    }
                }
            }
        }
        
        const lastWeekReport = await WeeklyShoppingReport.findOne({
            startDate: startDate - 7 * 24 * 3600 * 1000,
            endDate: startDate - 1
        }).exec();
        purchasedFoods.forEach((currentWeekFood) => {
            let percentageWithLastWeek = "";

            for (const lastWeekFood of lastWeekReport.purchasedFoods) {
                if (lastWeekFood.foodId === currentWeekFood.foodId) {
                    const lastWeekFoodQuantity = lastWeekFood.quantity;
                    const currentWeekFoodQuantity = currentWeekFood.quantity;
                    const percentage = Math.round((currentWeekFoodQuantity - lastWeekFoodQuantity) / lastWeekFoodQuantity * 100);
                    percentageWithLastWeek = percentage + "%";
                    if (percentage >= 0) {
                        percentageWithLastWeek = "+" + percentageWithLastWeek;
                    }
                    break;
                }
            }
            if (!percentageWithLastWeek) {
                percentageWithLastWeek = "+100%";
            }
            purchasedFoods.percentageWithLastWeek = percentageWithLastWeek;
        })

        const weeklyReport = await WeeklyShoppingReport.create({
            userId: userId,
            startDate: startDate,
            endDate: endDate,
            purchasedFoods: purchasedFoods
        })
        return weeklyReport;
    } catch (error) {
        console.log(error);
        return null;
    }
}

async function getWeeklyReport(req, res) {
    const { startDate, endDate } = req.query;
    const userId = res.locals.userId;

    try {
        const startDateInDate = new Date(startDate);
        const endDateInDate = new Date(endDate);
        endDateInDate.setUTCHours(23, 59, 59);
        let weeklyReport;
        // console.log(startDate);
        // console.log(endDate)
        // console.log(startDateInDate);
        // console.log(endDateInDate);
        // const test = new Date("2024-12-29");
        // test.setUTCHours(23, 59, 59);
        // console.log(test);
        // if (startDate + 7 * 24 * 3600 * 1000 - 1 === endDate) {
            weeklyReport = await WeeklyShoppingReport.findOne({
                startDate: startDateInDate,
                endDate: endDateInDate
            }).populate({
                path: "purchasedFoods.foodId",
                select: "name unitId",
                populate: {
                    path: "unitId",
                    select: "name"
                }
            }).exec();
        // } else {
        //     weeklyReport = await createWeeklyReport(userId, startDate, endDate);
        // }

        if (weeklyReport) {
            return res.status(200).json(weeklyReport);
        } else {
            // return res.status(400).json({ message: "There has errors while processing in server."});
            return res.status(400).json({ message: "No data."});

        }
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
}

async function createWeeklyReportManually() {
    try {
        const report1 = await WeeklyShoppingReport.create({
            userId: new ObjectId("6762a2cfe814cbe8bb9f8960"),
            startDate: new Date("2024-12-16"),
            endDate: new Date("2024-12-22T23:59:59.000Z"),
            purchasedFoods: [
                {
                    foodId: "675814a4d847921ab555b99f",//thịt lợn
                    quantity: 3.5,
                    percentageWithLastWeek: "+15%"
                },
                {
                    foodId: "675818c8d731b4b886068090",//thịt bò
                    quantity: 2.5,
                    percentageWithLastWeek: "+10%"
                },
                {
                    foodId: "67721664a24acc6a60cde13c",//cá bạc má
                    quantity: 12,
                    percentageWithLastWeek: "+5%"
                },
                {
                    foodId: "675821a7d731b4b886068119",//rau muống
                    quantity: 5,
                    percentageWithLastWeek: "+5%"
                },
                {
                    foodId: "67582205d731b4b886068126",//bắp cải
                    quantity: 3,
                    percentageWithLastWeek: "-10%"
                },
                {
                    foodId: "6758224ad731b4b88606812f",//cà rốt
                    quantity: 4,
                    percentageWithLastWeek: "+10%"
                },
                {
                    foodId: "67581fb7d731b4b8860680e1",//tôm thẻ
                    quantity: 5,
                    percentageWithLastWeek: "+15%"
                },
                {
                    foodId: "6758247b98f31adbd201b934",//cà chua
                    quantity: 5,
                    percentageWithLastWeek: "-12%"
                },
                {
                    foodId: "6758259a98f31adbd201b94e",//táo
                    quantity: 5,
                    percentageWithLastWeek: "+0%"
                },                
            ]
        });

        const report2 = await WeeklyShoppingReport.create({
            userId: new ObjectId("6762a2cfe814cbe8bb9f8960"),
            startDate: new Date("2024-12-23"),
            endDate: new Date("2024-12-29T23:59:59.000Z"),
            purchasedFoods: [
                {
                    foodId: "677215cfa24acc6a60cde131",//thịt gà
                    quantity: 4,
                    percentageWithLastWeek: "+10%"
                },
                {
                    foodId: "675814a4d847921ab555b99f",//thịt lợn
                    quantity: 3,
                    percentageWithLastWeek: "-10%"
                },
                {
                    foodId: "675818c8d731b4b886068090",//thịt bò
                    quantity: 2.5,
                    percentageWithLastWeek: "+10%"
                },
                {
                    foodId: "67721629a24acc6a60cde138",//cá thu
                    quantity: 2.5,
                    percentageWithLastWeek: "+5%"
                },
                {
                    foodId: "67721683a24acc6a60cde144",//cá chim
                    quantity: "3",
                    percentageWithLastWeek: "+0%"
                },
                {
                    foodId: "675821a7d731b4b886068119",//rau muống
                    quantity: 6,
                    percentageWithLastWeek: "+10%"
                },
                {
                    foodId: "67582226d731b4b886068129",//cải thìa
                    quantity: 3,
                    percentageWithLastWeek: "-10%"
                },
                {
                    foodId: "67582268d731b4b886068136",//khoai tây
                    quantity: 5,
                    percentageWithLastWeek: "+10%"
                },
                {
                    foodId: "675820aad731b4b8860680f0",//cua thịt
                    quantity: 4,
                    percentageWithLastWeek: "+100%"
                },
                {
                    foodId: "6758247b98f31adbd201b934",//cà chua
                    quantity: 5,
                    percentageWithLastWeek: "-12%"
                },
                {
                    foodId: "675825ea98f31adbd201b95a",//xoài
                    quantity: 5,
                    percentageWithLastWeek: "+0%"
                },                
            ]
        });
        console.log("insert ok");
    } catch (error) {
        console.log(error);
    }
}

async function weeklyExecuteCreatingReport() {
    try {
        const users = await User.find({}, "_id").exec();
        const currentDate = new Date();
        const distanceWithSunday = currentDate.getDay() === 0 ? 0 : 7 - currentDate.getDay();

        let timeToDelay;
        let sundayDate = new Date(currentDate.getTime());
        sundayDate.setDate(currentDate.getDate() + distanceWithSunday);
        sundayDate.setHours(23, 59, 59, 999);
        timeToDelay = sundayDate.getTime() - currentDate.getTime() + 999;
        const mondayDate = new Date(sundayDate.getTime() - 24 * 7 * 3600 * 1000 + 1);

        setInterval(async () => {
            for (const user of users) {
                await createWeeklyReport(user.userId, mondayDate, sundayDate);
                timeToDelay = 24 * 7 * 3600 * 1000;
            }
        }, timeToDelay);        
    } catch (error) {
        console.log(error);
    }

}

module.exports = {
    createWeeklyReport,
    createWeeklyReportManually,
    getWeeklyReport
}
