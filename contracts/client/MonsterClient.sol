// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface MonsterClient {
    function mintMany(address account,uint256 amount) external;
    function mint(address account) external;
}