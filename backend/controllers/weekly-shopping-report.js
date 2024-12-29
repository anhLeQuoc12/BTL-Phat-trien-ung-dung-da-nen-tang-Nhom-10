const WeeklyShoppingReport = require("../models/weekly-shopping-report");

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
        endDateInDate.setHours(23, 59, 59);
        let weeklyReport;
        // if (startDate + 7 * 24 * 3600 * 1000 - 1 === endDate) {
            weeklyReport = await WeeklyShoppingReport.findOne({
                startDate: startDateInDate,
                endDate: endDateInDate
            }).exec();
        // } else {
        //     weeklyReport = await createWeeklyReport(userId, startDate, endDate);
        // }

        if (weeklyReport) {
            return res.status(200).json(weeklyReport);
        } else {
            return res.status(400).json({ message: "There has errors while processing in server."});
        }
    } catch (error) {
        return res.status(500).json({ message: error.message });
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
    getWeeklyReport
}
