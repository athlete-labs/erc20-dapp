const AthleteToken = artifacts.require("AthleteToken");

module.exports = function (deployer) {
  deployer.deploy(AthleteToken);
};
