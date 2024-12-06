const { Schema, SchemaTypes, model } = require("mongoose");

const weeklyShoppingReportSchema = new Schema({
    userId: {
        type: SchemaTypes.ObjectId,
        ref: User,
        required: true
    },
    startDate: {
        type: Date,
        required: true
    },
    endDate: {
        type: Date,
        required: true
    },
    purchasedFoods: [
        {
            foodId: {
                type: SchemaTypes.ObjectId,
                ref: Food,
                required: true
            },
            quantity: {
                type: Number,
                required: true
            },
            percentageWithLastWeek: {
                type: String,
                required: true
            }
        }
    ]
})

const WeeklyShoppingReport = model("WeeklyShoppingReport", weeklyShoppingReportSchema);
module.exports = WeeklyShoppingReport;
