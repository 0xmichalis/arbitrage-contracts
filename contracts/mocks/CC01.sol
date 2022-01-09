//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CC01 is ERC20 {
    constructor() ERC20("CC01", "CC01") {
        _mint(msg.sender, 1000000000 * 10 ** decimals());
    }
}
