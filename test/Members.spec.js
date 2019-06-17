const DAO = artifacts.require("./KuknosDAO.sol")
const { getContract } = require("./configContract");

contract("Members", (accounts) => {
    var ct;
    beforeEach(() => ct || getContract(DAO, accounts).then(instance => ct = instance))

    it("members count", () =>
        ct.membersCount()
            .then(count => assert.equal(count, 4))
    )

    it("members list", () =>
        ct.membersList()
            .then(list => assert.equal(list.length, 4))
    )

})