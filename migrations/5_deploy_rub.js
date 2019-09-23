var EnfaceRub = artifacts.require("./EnfaceRub.sol");

module.exports = function(deployer) {
  deployer.deploy(EnfaceRub, 0);
};
