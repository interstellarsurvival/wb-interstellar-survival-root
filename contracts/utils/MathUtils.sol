// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MathUtils{
    uint256 total;
    function random(uint256 size) public returns (uint) {
        total++;
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp,total))) % size;
    }

    function bytesToUint(bytes memory b) public pure returns (uint256 number) {
        for(uint i = 0; i < b.length; i++) {
            number = number + uint8(b[i])*(2**(8*(b.length-(i+1))));
        }
    }
}