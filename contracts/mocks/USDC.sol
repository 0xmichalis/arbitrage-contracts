//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDC is ERC20 {
    constructor() ERC20("USDC", "USDC") {
        _mint(msg.sender, 1000000000 * 10 ** 6);
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }
}
