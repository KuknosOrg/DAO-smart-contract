const Voting = artifacts.require("./KuknosDAO.sol")

module.exports = function (deployer, network, accounts) {
	deployer.deploy(Voting, accounts.slice(0, accounts.length - 1), 50);
};