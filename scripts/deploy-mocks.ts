// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";
import * as dotenv from "dotenv";
import { BigNumber, Contract } from "ethers";

dotenv.config();

const routerAddress = process.env.LIQUIDITY_ROUTER ? process.env.LIQUIDITY_ROUTER: "";
const uniRouterAbi = new ethers.utils.Interface([
    'function addLiquidity(address tokenA,address tokenB,uint amountADesired,uint amountBDesired,uint amountAMin,uint amountBMin,address to,uint deadline) external returns (uint amountA, uint amountB, uint liquidity)',
]);

async function addLiquidity(
    a: Contract,
    b: Contract,
    amountA: number,
    amountB: number
) {
    const [me] = await ethers.getSigners()
    if (await a.allowance(me.address, routerAddress) == 0) {
        await a.approve(routerAddress, BigNumber.from(Number.MAX_SAFE_INTEGER));
    }
    if (await b.allowance(me.address, routerAddress) == 0) {
        await b.approve(routerAddress, BigNumber.from(Number.MAX_SAFE_INTEGER));
    }
    const router = new ethers.Contract(routerAddress, uniRouterAbi);
    await router.addLiquidity(
        a.address,
        b.address,
        amountA,
        amountB,
        amountA,
        amountB,
        me,
        Date.now() + 3600
    );
}

async function main() {
    // Deploy mocks
    const USDC = await ethers.getContractFactory("USDC");
    const usdc = await USDC.deploy();
    await usdc.deployed();
    console.log("USDC deployed to:", usdc.address);

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

    // Deploy liquidity

    // 40M USDC
    // 20M CC01
    // CC01 price: 2 USDC
    const usdcAmount = 40000000 * 1e6;
    const cc01Amount = 20000000 * 1e18;
    await addLiquidity(usdc, cc01, usdcAmount, cc01Amount);
    console.log("USDC/CC01 liquidity addded");

    // 5M PERIVALON
    // 20M CC01
    // PERIVALON price: 8 USDC
    const pAmount = 5000000 * 1e9;
    await addLiquidity(perivalon, cc01, pAmount, cc01Amount);
    console.log("PERIVALON/CC01 liquidity addded");

    // 40M USDC
    // 10M CC02
    // CC02 price: 4 USDC
    const cc02Amount = 10000000 * 1e18;
    await addLiquidity(usdc, cc02, usdcAmount, cc02Amount);
    console.log("USDC/CC02 liquidity addded");

    // 4M PERIVALON
    // 10M CC02
    // PERIVALON price: 10 USDC
    const p2Amount = 4000000 * 1e9;
    await addLiquidity(perivalon, cc02, p2Amount, cc02Amount);
    console.log("PERIVALON/CC02 liquidity addded");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
