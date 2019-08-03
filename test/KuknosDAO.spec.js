const DAO = artifacts.require("./KuknosDAO.sol")
const { addDay, now } = require("./config/utils");
const { getContract } = require("./config/configContract");

contract("KuknosDAO", (accounts) => {
    var ct;
    beforeEach(() => ct || getContract(DAO, accounts).then(instance => ct = instance))

    it("registerAddAnchorProposal", () => {
        let ct;
        return getContract(DAO, accounts)
            .then(instance => ct = instance)
            .then(ct => ct.balanceOf(accounts[1]))
            .then(balance => assert.equal(balance, 50))
            .then(() => ct.registerAddOrUpdateAnchorProposal("test", "http://anchor.test", [accounts[8], accounts[9]], addDay(-1)(now()), addDay(0)(now() + 5000), "http://test.com", "123", 0, {
                from: accounts[1]
            }))
            .then(() => ct.getProposal(0))
            .then((proposal) => assert.equal(proposal.title, "add anchor"))
            .then(() => ct.balanceOf(accounts[1]))
            .then(balance => assert.equal(balance, 49))
            .then(() => ct.voteForProposal(0, 1, { from: accounts[1] }))
            .then(() => ct.voteForProposal(0, 1, { from: accounts[2] }))
            .then(() => ct.voteForProposal(0, 1, { from: accounts[3] }))
            .then(() => ct.voteForProposal(0, 1, { from: accounts[4] }))
            .then(() => wait(7000))
            .then(() => ct.runAddOrUpdateAnchorProposal(0, 0, { from: accounts[1] }))
            .then(() => ct.anchors(2))
            .then((anchor) => assert.equal(anchor.name, "test"))
            .then(() => ct.membersList())
            .then((list) => assert.equal(list.length, 6))
    }, 20000)

    it("registerRemoveAnchorProposal", () => {
        let ct;
        return getContract(DAO, accounts)
            .then(instance => ct = instance)
            .then(ct => ct.balanceOf(accounts[1]))
            .then(balance => assert.equal(balance, 50))
            .then(() => ct.registerAddOrUpdateAnchorProposal("anchor", addDay(-1)(now()), addDay(0)(now()), "http://test.com", "123", 0, {
                from: accounts[1]
            }))
            .then(() => ct.getProposal(0))
            .then((proposal) => assert.equal(proposal.title, "add anchor"))
            .then(() => ct.balanceOf(accounts[1]))
            .then(balance => assert.equal(balance, 49))
    })

})