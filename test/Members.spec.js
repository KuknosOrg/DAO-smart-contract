const DAO = artifacts.require("./KuknosDAO.sol")

contract("Members", (accounts) => {
    var ct;
    
    beforeEach(() => {
        return DAO.deployed().then(instance => ct = instance)
    })

    it("members count", () =>
        ct.membersCount()
            .then(count => assert.equal(count, 9))
    )

    it("members list", () =>
        ct.membersList()
            .then(list => assert.equal(list.length, 9))
    )

})