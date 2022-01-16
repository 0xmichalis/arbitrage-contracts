//SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PERIVALON is ERC20 {
    constructor() ERC20("PERIVALON", "PERIVALON") {
        _mint(msg.sender, 1000000000 * 10 ** decimals());
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }
}
