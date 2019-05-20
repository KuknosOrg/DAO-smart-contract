const Voting = artifacts.require("./Voting.sol")

contract("AccessToken", (accounts) => {
    var ct;
    it("get instance", () => Voting.deployed().then(instance => ct = instance))
    it("check access token count", () =>
        ct.accessTokensCount()
            .then(count => assert.equal(count, 50))
    )
    it("check balance of account", () =>
        ct.balanceOf(accounts[1])
            .then(balance => assert.equal(balance, 50))
    )
})