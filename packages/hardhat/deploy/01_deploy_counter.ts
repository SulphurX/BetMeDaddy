import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deployCounter: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  await deploy("Counter", {
    from: deployer,
    args: [],
    log: true,
    autoMine: true,
  });

  const counter = await hre.ethers.getContract("Counter", deployer);
  console.log("Counter deployed to:", counter.target);
};

export default deployCounter;
deployCounter.tags = ["Counter"];
