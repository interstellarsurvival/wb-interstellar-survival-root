// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TimeUtil {
    function currentTime() public view returns (uint) {
        unchecked {
            return block.timestamp;
        }
    }
}