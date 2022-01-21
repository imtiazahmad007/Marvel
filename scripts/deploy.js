// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const SwagToken = await hre.ethers.getContractFactory("DailyRewards", {
    libraries: {
      IterableMapping: "0xb434c910e1dd843aa8e80b5373b4ada9f34d3f2e"
    }
  });
  const swag = await SwagToken.deploy("Daily Rewards Token", "DRT");

  await swag.deployed();

  console.log("Swag deployed to:", swag.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
