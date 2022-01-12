// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct StatusResult { bool ifHas; bool isDone; uint8 mapId; uint startTime; uint reward; }

interface ApiQueryClient {
    function getCurrentStatus(uint256 tokenId, uint mapId) external view returns (StatusResult memory statusResult);
}