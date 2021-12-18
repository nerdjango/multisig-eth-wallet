const truffleAssert = require("truffle-assertions")

const Wallet = artifacts.require("MultiSigWallet");

contract("Escrow", accounts => {
    it("should allow deposit from any user", async() => {
        let wallet = await Wallet.deployed()

        await wallet.deposit({ value: 1000 }) //deposits 1000wei
        let contractBalance = await wallet.getBalance()
        assert.equal(contractBalance.toNumber(), 1000)
    })
    it("should allow only owners to execute transfers", async() => {
        let wallet = await Wallet.deployed()

        await truffleAssert.reverts(wallet.makeTransfer(accounts[4], 1000, { from: accounts[5] })) // accounts 5 tries sending the balance to accounts 4 but it reverts as accounts 5 is not an owner
        await truffleAssert.passes(wallet.makeTransfer(accounts[4], 1000, { from: accounts[0] }))
        let contractBalance = await wallet.getBalance()
        assert.equal(contractBalance.toNumber(), 1000) //confirms that the amount sent yet as we need more confirmations
    })
    it("should allow only owners to approve transfers", async() => {
        let wallet = await Wallet.deployed()

        await truffleAssert.reverts(wallet.approveTransfer(0, { from: accounts[5] })) // accounts 5 tries approving transaction but it reverts as accounts 5 is not an owner
        await truffleAssert.reverts(wallet.approveTransfer(0, { from: accounts[0] })) // can not approve twice. By making a transfer account 0 has automatically approved the transaction
        let contractBalance = await wallet.getBalance()
        assert.equal(contractBalance.toNumber(), 1000) //confirms that the amount sent yet as we need more confirmations

        await truffleAssert.passes(wallet.approveTransfer(0, { from: accounts[1] })) // 2 out of 4 won't transfer
        contractBalance = await wallet.getBalance()
        assert.equal(contractBalance.toNumber(), 1000) // confirms that the amount is not sent yet as we need more confirmations

        await truffleAssert.passes(wallet.approveTransfer(0, { from: accounts[2] })) // 3 out of 4 validates transfer
        contractBalance = await wallet.getBalance()
        assert.equal(contractBalance.toNumber(), 0) // confirms that the amount is sent
    })
})