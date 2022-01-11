// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";


async function main() {
    // Deploy mocks
    const PERIVALON = await ethers.getContractFactory("PERIVALON");
    const perivalon = await PERIVALON.deploy();
    await perivalon.deployed();
    console.log("PERIVALON deployed to:", perivalon.address);

    const CC01 = await ethers.getContractFactory("CC01");
    const cc01 = await CC01.deploy();
    await cc01.deployed();
    console.log("CC01 deployed to:", cc01.address);

    const CC02 = await ethers.getContractFactory("CC02");
    const cc02 = await CC02.deploy();
    await cc02.deployed();
    console.log("CC02 deployed to:", cc02.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
