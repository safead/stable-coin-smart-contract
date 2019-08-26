var EnfaceCurrency = artifacts.require("./EnfaceCurrency.sol");

module.exports = function(deployer) {
  deployer.deploy(EnfaceCurrency, 0);
};
