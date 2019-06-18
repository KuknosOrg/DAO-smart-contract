const DAO = artifacts.require("./KuknosDAO.sol")
const { getContract } = require("./config/configContract");

contract("AccessToken", (accounts) => {
    var ct;
    beforeEach(() => ct || getContract(DAO, accounts).then(instance => ct = instance))

    it("check access token count", () =>
        ct.accessTokensCount()
            .then(count => assert.equal(count, 50))
    )
    it("check balance of account", () =>
        ct.balanceOf(accounts[2])
            .then(balance => assert.equal(balance, 50))
    )
})