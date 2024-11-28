const allRoles = {
  user: [],
  admin: [],
};

const roles = Object.keys(allRoles);
const roleRights = new Map(Object.entries(allRoles));

const roleMap = {
  user: "user",
  admin: "admin",
};

module.exports = {
  roles,
  roleRights,
  roleMap,
};
