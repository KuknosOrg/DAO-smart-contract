const Voting = artifacts.require("./Voting.sol")

contract("Voting", (accounts) => {
    var ct;
    it("get instance", () => Voting.deployed().then(instance => ct = instance))
    it("check owner", () =>
        ct.owner()
            .then(owner => assert.equal(owner, accounts[0]))
    )
    it("transferOwnership", () =>
        ct.transferOwnership(accounts[1], {
            from: accounts[0]
        })
            .then(() => ct.owner())
            .then(owner => assert.equal(owner, accounts[1]))
            .then(() => ct.transferOwnership(accounts[0], {
                from: accounts[1]
            }))
            .then(() => ct.owner())
            .then(owner => assert.equal(owner, accounts[0]))
    )
    it("renounceOwnership", () =>
        ct.renounceOwnership({
            from: accounts[0]
        })
            .then(() => ct.owner())
            .then(owner => assert.equal(owner, 0))
    )
})