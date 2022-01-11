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
     *  VARIABLES
     ***********************************************/

    /// @notice Lending pool that supports flashloans
    ILendingPool private immutable lendingPool;
    /// @notice Router to execute swaps
    IUniswapV2Router02 private immutable router;
    /// @notice Keeper is allowed to execute flashloans
    address private keeper;

    /************************************************
     *  CONSTRUCTOR
     ***********************************************/

    /**
        @param _provider Lending provider that supports flashloans
        @param _router Router to execute swaps
        @param _asset Asset being arbed; increasing router's allowance
        @param _keeper Keeper role, can request flashloans
     */
    constructor(
        ILendingPoolAddressesProvider _provider,
        IUniswapV2Router02 _router,
        address _asset,
        address _keeper
    ) payable {
        lendingPool = ILendingPool(_provider.getLendingPool());
        router = _router;
        keeper = _keeper;
        IERC20(_asset).approve(address(_router), type(uint256).max);
    }

    /************************************************
     *  FLASHLOAN REQUEST
     ***********************************************/

    /**
        @notice Request a flashloan to be executed
        @param asset Asset to borrow
        @param amount Amount to borrow
        @param path Complete path to follow in executeOperation
     */
    function flashloan(
        address asset,
        uint256 amount,
        address[] calldata path
    ) public {
        require(msg.sender == owner() || msg.sender == keeper, "invalid sender");

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
            address(this), // on-behalf-of
            abi.encode(path), // params
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
        returns (bool)
    {
        require(initiator == address(this) || initiator == owner() || initiator == keeper, "invalid initiator");
        address[] memory path = abi.decode(params, (address[]));

        // Execute swap
        uint[] memory amountsOut = router.swapExactTokensForTokens(
            amounts[0],
            0,
            path,
            address(this),
            block.timestamp + 300
        );

        // At the end of our logic above, we owe the flashloaned amounts + premiums.
        // Therefore we need to ensure we have enough to repay these amounts.
        // Approve the LendingPool contract allowance to *pull* the owed amount
        uint amountOwing = amounts[0] + premiums[0];
        require(amountsOut[path.length - 1] > amountOwing, "not enough funds swept");
        IERC20(assets[0]).approve(address(lendingPool), amountOwing);

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
