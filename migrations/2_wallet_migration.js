const Wallet = artifacts.require("MultiSigWallet");

module.exports = function(deployer, accounts) {
    adminList = [
        "0x2f1ea7f93dc8fa1c4281e206ed787aa5f69bb1c4",
        "0x016797a3c0430cc564f018036a3ad72e66e0ecf3",
        "0x1933d325fd1c8d5ed846d60b9fe5c85f7e141107"
    ]
    deployer.deploy(Wallet, adminList);
};