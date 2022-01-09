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

const routerAddress = process.env.LIQUIDITY_ROUTER ? process.env.LIQUIDITY_ROUTER: "";
const uniRouterAbi = new ethers.utils.Interface([
    'function addLiquidity(address tokenA,address tokenB,uint amountADesired,uint amountBDesired,uint amountAMin,uint amountBMin,address to,uint deadline) external returns (uint amountA, uint amountB, uint liquidity)',
]);

async function addLiquidity(
    me: SignerWithAddress,
    a: Contract,
    b: Contract,
    amountA: number,
    amountB: number
) {
    if (await a.allowance(me.address, routerAddress) == 0) {
        console.log(`Approving router in ${a.address}`);
        await a.approve(routerAddress, BigNumber.from(Number.MAX_SAFE_INTEGER));
    }
    if (await b.allowance(me.address, routerAddress) == 0) {
        console.log(`Approving router in ${b.address}`);
        await b.approve(routerAddress, BigNumber.from(Number.MAX_SAFE_INTEGER));
    }
    const router = new ethers.Contract(routerAddress, uniRouterAbi);
    console.log(`Adding liquidity for ${a.address}/${b.address}`);
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

const erc20Abi = new ethers.utils.Interface([
    'function approve(address spender, uint256 amount) external',
    'function allowance(address owner, address spender) external view returns(uint256)',
]);

async function main() {
    const [me] = await ethers.getSigners()

    // Update mocks with proper addresses here
    const usdc = new ethers.Contract("FILLME", erc20Abi, me);
    const perivalon = new ethers.Contract("FILLME", erc20Abi, me);
    const cc01 = new ethers.Contract("FILLME", erc20Abi, me);
    const cc02 = new ethers.Contract("FILLME", erc20Abi, me);

    // Deploy liquidity

    // 40M USDC
    // 20M CC01
    // CC01 price: 2 USDC
    const usdcAmount = 40000000 * 1e6;
    const cc01Amount = 20000000 * 1e18;
    await addLiquidity(me, usdc, cc01, usdcAmount, cc01Amount);
    console.log("USDC/CC01 liquidity addded");

    // 5M PERIVALON
    // 20M CC01
    // PERIVALON price: 8 USDC
    const pAmount = 5000000 * 1e9;
    await addLiquidity(me, perivalon, cc01, pAmount, cc01Amount);
    console.log("PERIVALON/CC01 liquidity addded");

    // 40M USDC
    // 10M CC02
    // CC02 price: 4 USDC
    const cc02Amount = 10000000 * 1e18;
    await addLiquidity(me, usdc, cc02, usdcAmount, cc02Amount);
    console.log("USDC/CC02 liquidity addded");

    // 4M PERIVALON
    // 10M CC02
    // PERIVALON price: 10 USDC
    const p2Amount = 4000000 * 1e9;
    await addLiquidity(me, perivalon, cc02, p2Amount, cc02Amount);
    console.log("PERIVALON/CC02 liquidity addded");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
