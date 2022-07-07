// contracts/AthleteToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AthleteToken is ERC20 {

    constructor() ERC20("Athlete Token", "ATH") {
        _mint(msg.sender, 100000000000000000);
    }

    function decimals() public view virtual override returns (uint8) {
        return 8;
    }
}