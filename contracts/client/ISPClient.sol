// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISPClient {
    function rateBurn(address account, uint256 amount) external;
    function mint(address account, uint256 amount) external;
}