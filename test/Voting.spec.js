const DAO = artifacts.require("./KuknosDAO.sol")
const { addDay, now, zeroAddress } = require("./utils");

contract("Voting", (accounts) => {
    var ct;

    beforeEach(() => {
        return DAO.deployed().then(instance => ct = instance)
    })

    it("registerProposal", () =>
        ct.balanceOf(accounts[0])
            .then(balance => assert.equal(balance, 50))
            .then(() => ct.registerProposal(1, "test", 1, addDay(-1)(now()), addDay(8)(now()), "http://test.com", new Uint32Array(), zeroAddress(), {
                from: accounts[0]
            }))
            .then(() => ct.getProposal(0))
            .then((proposal) => assert.equal(proposal[1], "test"))
            .then(() => ct.balanceOf(accounts[0]))
            .then(balance => assert.equal(balance, 49))
    )

    it("voteForProposal", () =>
        ct.voteForProposal(0, 1, { from: accounts[0] })
            .then(() => ct.voteForProposal(0, -1, { from: accounts[1] }))
            .then(() => ct.getProposal(0))
            .then((proposal) => {
                assert.equal(proposal[9], 1);
                assert.equal(proposal[10], 1);
            })
    )

})
