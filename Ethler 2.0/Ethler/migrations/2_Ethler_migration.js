const contract = artifacts.require("Ethler");

module.exports = function(deployer) {
  deployer.deploy(contract, {value: web3.utils.toWei("0.5","ether"), gas: 6000000});
};
