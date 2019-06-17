const DAO = artifacts.require("./KuknosDAO.sol")
const { addDay, now } = require("./utils");
const { getContract } = require("./configContract");

contract("KuknosDAO", (accounts) => {
    var ct;
    beforeEach(() => ct || getContract(DAO, accounts).then(instance => ct = instance))

    it("registerAddAnchorProposal", () => {
        let ct;
        return getContract(DAO, accounts)
            .then(instance => ct = instance)
            .then(ct => ct.balanceOf(accounts[1]))
            .then(balance => assert.equal(balance, 50))
            .then(() => ct.registerAddAnchorProposal("anchor", "http://anchor.test", [accounts[8], accounts[9]], addDay(-1)(now()), addDay(8)(now()), "http://test.com", "123", {
                from: accounts[1]
            }))
            .then(() => ct.proposals(0))
            .then((proposal) => assert.equal(proposal.title, "add anchor"))
            .then(() => ct.balanceOf(accounts[1]))
            .then(balance => assert.equal(balance, 49))
    })

})