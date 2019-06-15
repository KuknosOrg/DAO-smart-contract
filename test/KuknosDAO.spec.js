const DAO = artifacts.require("./KuknosDAO.sol")
const { addDay, now } = require("./utils");

contract("KuknosDAO", (accounts) => {
    var ct;

    beforeEach(() => {
        return DAO.deployed().then(instance => ct = instance)
    })

    it("registerAddAnchorProposal", () =>
        ct.balanceOf(accounts[0])
            .then(balance => assert.equal(balance, 50))
            .then(() => ct.registerAddAnchorProposal("anchor", "http://anchor.test", [accounts[1], accounts[2]], addDay(-1)(now()), addDay(8)(now()), "http://test.com", new Uint32Array(), {
                from: accounts[0]
            }))
            .then(() => ct.getProposal(0))
            .then((proposal) => assert.equal(proposal[1], "add anchor"))
            .then(() => ct.balanceOf(accounts[0]))
            .then(balance => assert.equal(balance, 49))
    )

})