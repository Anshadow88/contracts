//SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0 <0.9.0;

interface WETH {
    function transfer(address dst, uint256 wad) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);

    function balanceOf(address guy) external view returns (uint256);
}
