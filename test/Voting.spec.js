const DAO = artifacts.require("./KuknosDAO.sol")
const { addDay, now, zeroAddress } = require("./config/utils");
const { getContract } = require("./config/configContract");

contract("Voting", (accounts) => {
    var ct;
    beforeEach(() => ct || getContract(DAO, accounts).then(instance => ct = instance))

    it("registerProposal", () =>
        ct.balanceOf(accounts[1])
            .then(balance => assert.equal(balance, 50))
            .then(() => ct.registerProposal(1, "test", 1, addDay(-1)(now()), addDay(8)(now()), "http://test.com", "951", zeroAddress(), {
                from: accounts[1]
            }))
            .then(() => ct.proposals(0))
            .then((proposal) => assert.equal(proposal.title, "test"))
            .then(() => ct.balanceOf(accounts[1]))
            .then(balance => assert.equal(balance, 49))
    )

    it("voteForProposal", () =>
        ct.voteForProposal(0, 1, { from: accounts[2] })
            .then(() => ct.voteForProposal(0, -1, { from: accounts[3] }))
            .then(() => ct.proposals(0))
            .then((proposal) => {
                assert.equal(proposal.up, 1);
                assert.equal(proposal.down, 1);
            })
    )

})
