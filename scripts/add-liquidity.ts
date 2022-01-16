// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";
import * as dotenv from "dotenv";
import { BigNumber, Contract } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

dotenv.config();

const router0 = process.env.LIQUIDITY_ROUTER_0 ? process.env.LIQUIDITY_ROUTER_0: "";
const router1 = process.env.LIQUIDITY_ROUTER_1 ? process.env.LIQUIDITY_ROUTER_1: "";
const uniRouterAbi = new ethers.utils.Interface([
    'function addLiquidity(address tokenA,address tokenB,uint amountADesired,uint amountBDesired,uint amountAMin,uint amountBMin,address to,uint deadline) external returns (uint amountA, uint amountB, uint liquidity)',
]);

async function addLiquidity(
    me: SignerWithAddress,
    a: Contract,
    b: Contract,
    amountA: BigNumber,
    amountB: BigNumber,
    isFirst: boolean
) {
    const routerAddress = isFirst ? router0 : router1;
    const aAllowance = await a.allowance(me.address, routerAddress)
    const aAllowanceBN = BigNumber.from(aAllowance)
    if (aAllowanceBN.lt(amountA)) {
        console.log(`Approving ${isFirst ? "first": "second"} router in ${a.address}`)
        const tx = await a.approve(routerAddress, amountA);
        await tx.wait();
    }
    const bAllowance = await b.allowance(me.address, routerAddress)
    const bAllowanceBN = BigNumber.from(bAllowance)
    if (bAllowanceBN.lt(amountB)) {
        console.log(`Approving ${isFirst ? "first": "second"} router in ${b.address}`)
        const tx = await b.approve(routerAddress, amountB);
        await tx.wait();
    }
    const router = new ethers.Contract(routerAddress, uniRouterAbi, me);
    console.log(`Adding liquidity in ${isFirst ? "first": "second"} router for pair ${a.address} x ${b.address}`)
    const tx = await router.addLiquidity(
        a.address,
        b.address,
        amountA,
        amountB,
        amountA,
        amountB,
        me.address,
        Date.now() + 3600
    );
    await tx.wait();
}

const erc20Abi = new ethers.utils.Interface([
    'function approve(address spender, uint256 amount) external',
    'function allowance(address owner, address spender) external view returns(uint256)',
]);

async function main() {
    const [me] = await ethers.getSigners()

    // Update mocks with proper addresses here
    const usdc = new ethers.Contract("0x13512979ade267ab5100878e2e0f485b568328a4", erc20Abi, me);
    const perivalon = new ethers.Contract("FILLME", erc20Abi, me);
    const cc01 = new ethers.Contract("FILLME", erc20Abi, me);
    const cc02 = new ethers.Contract("FILLME", erc20Abi, me);

    // Deploy liquidity

    // 40M USDC
    // 20M CC01
    // CC01 price: 2 USDC
    const usdcAmount = ethers.utils.parseUnits("40000000", 6);
    const cc01Amount = ethers.utils.parseUnits("20000000");
    await addLiquidity(me, usdc, cc01, usdcAmount, cc01Amount, true);
    console.log("USDC/CC01 liquidity addded");

    // 5M PERIVALON
    // 20M CC01
    // PERIVALON price: 8 USDC
    const pAmount = ethers.utils.parseUnits("5000000", 9);
    await addLiquidity(me, perivalon, cc01, pAmount, cc01Amount, true);
    console.log("PERIVALON/CC01 liquidity addded");

    // 40M USDC
    // 20M CC02
    // CC02 price: 2 USDC
    const cc02Amount = ethers.utils.parseUnits("20000000");
    await addLiquidity(me, usdc, cc02, usdcAmount, cc02Amount, false);
    console.log("USDC/CC02 liquidity addded");

    // 4M PERIVALON
    // 10M CC02
    // PERIVALON price: 5 USDC
    const p2Amount = ethers.utils.parseUnits("4000000", 9);
    const cc202Amount = ethers.utils.parseUnits("10000000");
    await addLiquidity(me, perivalon, cc02, p2Amount, cc202Amount, false);
    console.log("PERIVALON/CC02 liquidity addded");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
