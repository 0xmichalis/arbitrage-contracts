// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";
import * as dotenv from "dotenv";

dotenv.config();

async function main() {
  const provider = process.env.LENDING_POOL_PROVIDER
    ? process.env.LENDING_POOL_PROVIDER
    : "";
  const router = process.env.LIQUIDITY_ROUTER
    ? process.env.LIQUIDITY_ROUTER
    : "";
  const asset = process.env.BORROWED_ASSET ? process.env.BORROWED_ASSET : "";
  const keeper = process.env.KEEPER_ADDRESS ? process.env.KEEPER_ADDRESS : "";

  const FlashLoan = await ethers.getContractFactory("FlashLoan");
  const flashloan = await FlashLoan.deploy(provider, router, asset, keeper);
  await flashloan.deployed();

  console.log("FlashLoan deployed to:", flashloan.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
