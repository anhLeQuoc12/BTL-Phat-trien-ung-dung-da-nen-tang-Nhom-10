async function changeUserInfo(req, res) {
    const { newPhone, newEmail } = req.body;
    const userId = res.locals.userId;

    try {
        const updateObject = {};
        if (newPhone) {
            updateObject.newPhone = newPhone;
        }
        if (newEmail) {
            updateObject.newEmail = newEmail;
        }
        const user = await User.findOneAndUpdate({
            _id: userId
        }, updateObject).exec();
        return res.status(200).json(user);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
}
