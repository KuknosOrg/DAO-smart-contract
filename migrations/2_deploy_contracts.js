const DAO = artifacts.require("./KuknosDAO.sol")

module.exports = function (deployer, network, accounts) {
	deployer.deploy(DAO, 50);
};