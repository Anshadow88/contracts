//SPDX-License-Identifier:  GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(uint256 ts) ERC20("mockERC20", "testERC20") {
        _mint(msg.sender, ts * 10**18);
    }
}
