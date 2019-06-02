const Voting = artifacts.require("./Voting.sol")

contract("Voting", (accounts) => {
    var ct;
    
    beforeEach(() => {
        return Voting.deployed().then(instance => ct = instance)
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