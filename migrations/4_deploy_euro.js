var EnfaceEuro = artifacts.require("./EnfaceEuro.sol");

module.exports = function(deployer) {
  deployer.deploy(EnfaceEuro, 0);
};
