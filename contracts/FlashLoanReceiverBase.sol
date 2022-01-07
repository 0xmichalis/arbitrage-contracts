//SPDX-License-Identifier: Anti-996 License
pragma solidity ^0.8.10;

import "./interfaces/IFlashLoanReceiver.sol";
import "./interfaces/ILendingPoolAddressesProvider.sol";
import "./interfaces/ILendingPool.sol";

abstract contract FlashLoanReceiverBase is IFlashLoanReceiver {
  ILendingPool public immutable lendingPool;

  constructor(ILendingPoolAddressesProvider provider) payable {
    lendingPool = ILendingPool(provider.getLendingPool());
  }
}
