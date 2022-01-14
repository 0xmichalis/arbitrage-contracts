//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IFlashLoanReceiver.sol";
import "./interfaces/ILendingPool.sol";
import "./interfaces/ILendingPoolAddressesProvider.sol";
import "./interfaces/IUniswapV2Router02.sol";

/*
* This contract utilizes AAVE flashloans to arbitrage pairs
* in Uniswap v2 with certain characteristics:
*
* 1. It is assumed that the first and last assets in the path
*    provided to flashloan are the same so we have effectively
*    an arbitrage opportunity.
* 2. AAVE, or any lending platform that provides flashloans and
*    utilizes AAVE's interface, has to support lending that asset.
*/
contract FlashLoan is IFlashLoanReceiver, Ownable {
    /************************************************
     *  CONSTANTS & VARIABLES
     ***********************************************/

    /// @notice Lending pool that supports flashloans
    ILendingPool private immutable lendingPool;
    /// @notice Router to execute swaps
    IUniswapV2Router02 private immutable router0;
    /// @notice Router to execute swaps
    IUniswapV2Router02 private immutable router1;
    /// @notice Keeper is allowed to execute flashloans
    address private keeper;


    /************************************************
     *  MODIFIERS
     ***********************************************/

    modifier onlyLendingPool() {
        require(msg.sender == address(lendingPool), "!lendingPool");
        _;
    }

    modifier onlyKeeper() {
        require(msg.sender == keeper, "!keeper");
        _;
    }


    /************************************************
     *  CONSTRUCTOR
     ***********************************************/

    /**
        @param _provider Lending provider that supports flashloans
        @param _router0 Router to execute swaps
        @param _router1 Second router to execute swaps, in case there is need to swap across DEXs
        @param _asset0 Asset being arbed; increasing router0's allowance
        @param _asset1 Asset being arbed; increasing router1's allowance
     */
    constructor(
        ILendingPoolAddressesProvider _provider,
        IUniswapV2Router02 _router0,
        IUniswapV2Router02 _router1,
        address _asset0,
        address _asset1
    ) payable {
        require(address(_provider) != address(0), "!_provider");
        require(address(_router0) != address(0), "!_router0");
        require(address(_asset0) != address(0), "!_asset0");
        require(_asset1 != address(0), "!_asset1");

        lendingPool = ILendingPool(_provider.getLendingPool());
        router0 = _router0;
        router1 = _router1;
        keeper = msg.sender;

        // Insecure, but reduced gas in executeOperation
        IERC20(_asset0).approve(address(lendingPool), type(uint256).max);
        IERC20(_asset0).approve(address(_router0), type(uint256).max);
        IERC20(_asset1).approve(address(_router0), type(uint256).max);
        IERC20(_asset0).approve(address(_router1), type(uint256).max);
        IERC20(_asset1).approve(address(_router1), type(uint256).max);
    }

    /************************************************
     *  FLASHLOAN REQUEST
     ***********************************************/

    /**
        @notice Request a flashloan to be executed
        @param asset Asset to borrow
        @param amount Amount to borrow
        @param zeroToOne Direction of router usage; true means the first leg should be executed by router0, etc.
        @param path0 First leg of swap follow in executeOperation
        @param path1 Second leg of swap to follow in executeOperation
     */
    function flashloan(
        address asset,
        uint256 amount,
        bool zeroToOne,
        address[] calldata path0,
        address[] calldata path1
    ) public onlyKeeper {
        address[] memory assets = new address[](1);
        assets[0] = asset;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;

        // 0 = no debt, 1 = stable, 2 = variable
        uint256[] memory modes = new uint256[](1);
        modes[0] = 0;

        lendingPool.flashLoan(
            address(this), // receiving address
            assets,
            amounts,
            modes,
            address(0), // on-behalf-of
            abi.encode(zeroToOne, path0, path1), // params
            0 // referal code
        );
    }

    /************************************************
     *  FLASHLOAN CALLBACK
     ***********************************************/

    /**
        @notice This function is called after our contract has received the flash loaned amount
        @param assets Assets to borrow; should only be one
        @param amounts Amounts to borrow; should only be one
        @param premiums Premium to pay back on top of borrowed amount; should only be one
        @param initiator Account who initiated the flashloan
        @param params Custom parameters forwarded by the flashloan request; should be the path to swap
     */
    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    )
        external
        override
        onlyLendingPool
        returns (bool)
    {
        require(initiator == address(this), "invalid initiator");
        (
            bool zeroToOne,
            address[] memory path0,
            address[] memory path1
        ) = abi.decode(params, (bool, address[], address[]));

        IUniswapV2Router02 _router0;
        IUniswapV2Router02 _router1;
        if (zeroToOne) {
           _router0 = router0;
           _router1 = router1;
        } else {
           _router0 = router1;
           _router1 = router0;
        }

        // Execute first leg of the swap
        uint[] memory amountsOut = _router0.swapExactTokensForTokens(
            amounts[0],
            0,
            path0,
            address(this),
            block.timestamp + 300
        );

        // Execute second leg of the swap
        amountsOut = _router1.swapExactTokensForTokens(
            amountsOut[path0.length - 1],
            0,
            path1,
            address(this),
            block.timestamp + 300
        );

        // At the end of our logic above, we owe the flashloaned amounts + premiums.
        // Therefore we need to ensure we have enough to repay these amounts.
        uint amountOwing = amounts[0] + premiums[0];
        // It is assumed here that the client that constructs the path is trusted
        // and has done the construction properly, otherwise we may get rekt.
        require(amountsOut[path1.length - 1] > amountOwing, "not enough funds swept");

        return true;
    }

    /************************************************
     *  FUND RETRIEVAL
     ***********************************************/

    /**
        @notice Withdraw any type of token from the contract back to the owner
        @param asset Asset to withdraw
    */
    function withdraw(address asset) public {
        IERC20(asset).transfer(owner(), IERC20(asset).balanceOf(address(this)));
    }

    /************************************************
     *  MAINTENANCE
     ***********************************************/

    /**
        @notice Update keeper to a new address
        @param newKeeper New keeper address
    */
    function changeKeeper(address newKeeper) public onlyOwner {
        keeper = newKeeper;
    }
}
