//SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CC02 is ERC20 {
    constructor() ERC20("CC02", "CC02") {
        _mint(msg.sender, 1000000000 * 10 ** decimals());
    }
}
