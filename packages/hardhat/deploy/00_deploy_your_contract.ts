import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ReputationSystem } from "@typechain/hardhat";

const deployPredictionMarkets: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, network } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log("Deploying to Citrea with account:", deployer);

  // 1. Deploy Market Implementation
  const marketImpl = await deploy("Market", {
    from: deployer,
    args: [],
    log: true,
  });
  console.log("Market implementation deployed to:", marketImpl.address);

  // 2. Deploy ReputationSystem
  const reputationSystem = await deploy("ReputationSystem", {
    from: deployer,
    args: [deployer], // initialOwner
    log: true,
  });
  console.log("ReputationSystem deployed to:", reputationSystem.address);

  // 3. Deploy MarketFactory
  const marketFactory = await deploy("MarketFactory", {
    from: deployer,
    args: [
      deployer, // initialOwner
      marketImpl.address,
      reputationSystem.address,
    ],
    log: true,
  });
  console.log("MarketFactory deployed to:", marketFactory.address);

  // 4. Whitelist the MarketFactory in ReputationSystem
  const ReputationSystem = await hre.ethers.getContractFactory("ReputationSystem");
  const repSystem = ReputationSystem.attach(reputationSystem.address) as ReputationSystem;

  const whitelistTx = await repSystem.whitelistFactory(marketFactory.address);
  await whitelistTx.wait();
  console.log("MarketFactory whitelisted in ReputationSystem");

  // Log deployment addresses for verification
  console.log("\nDeployment Summary:");
  console.log("===================");
  console.log("Network:", network.name);
  console.log("Market Implementation:", marketImpl.address);
  console.log("ReputationSystem:", reputationSystem.address);
  console.log("MarketFactory:", marketFactory.address);
};

deployPredictionMarkets.tags = ["PredictionMarkets"];
export default deployPredictionMarkets;
