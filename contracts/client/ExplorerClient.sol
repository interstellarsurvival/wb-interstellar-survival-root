// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**** Explorer properties */
struct Explorers {
    uint8   body;           uint8   eyes;       uint8   mouse;          uint8   pigtail;
    uint8   helm;           uint8   weapon;     uint8   clothes;        uint8   feet;           uint8 back;
    uint16  ability;  uint16  level;      uint32  lvlProgress;
}

enum        Status  {   UNSTAKED, TRAINING, RAIDING, EXPLORING, HUNTING }
struct      Action  {   address owner;      uint startTime; Status status; }

interface ExplorerClient {
    function ownerOf(uint256 tokenId)external view returns (address);
    function isWorking(uint256 tokenId)external view returns (bool);
    function goHunting(uint256 tokenId) external;
    function returnBack(uint256 tokenId) external;
    function explorers(uint256 tokenId)external view returns(Explorers memory e);
    function getOwnerTokens(address addr) external view returns (uint256[] memory tokenIds);
    function activities(uint256 tokenId) external view returns(Action memory action);
}