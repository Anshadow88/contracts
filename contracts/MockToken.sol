//SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor() ERC20("mockERC20", "testERC20") {
        _mint(msg.sender, 1000 * 10**18);
    }
}
