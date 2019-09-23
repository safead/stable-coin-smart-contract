var EnfaceUsd = artifacts.require("./EnfaceUsd.sol");

module.exports = function(deployer) {
  deployer.deploy(EnfaceUsd, 0);
};
