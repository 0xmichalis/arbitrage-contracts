//SPDX-License-Identifier: Anti-996 License
pragma solidity ^0.8.10;

import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";

import { IFlashLoanReceiver } from "./interfaces/IFlashLoanReceiver.sol";
import { ILendingPoolAddressesProvider } from "./interfaces/ILendingPoolAddressesProvider.sol";
import { ILendingPool } from "./interfaces/ILendingPool.sol";

abstract contract FlashLoanReceiverBase is IFlashLoanReceiver {
  ILendingPoolAddressesProvider public immutable ADDRESSES_PROVIDER;
  ILendingPool public immutable LENDING_POOL;

  constructor(ILendingPoolAddressesProvider provider) payable {
    ADDRESSES_PROVIDER = provider;
    LENDING_POOL = ILendingPool(provider.getLendingPool());
  }
}