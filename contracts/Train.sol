// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./utils/TimeUtil.sol";
import "./client/ApiQueryClient.sol";

interface NFTClient {
    function backFrom(uint8 status, address to, uint256 tokenId, bytes calldata data) external returns (bool);
    function getCurrentLevelAndLvlProgress(uint256 tokenId) external returns (uint16 level, uint32 lvlProgress);
    function updateLevelAndLvlProgress(uint256 tokenId, uint16 targetLevel, uint32 targetLvlProgress) external;
}

contract Train is IERC721ReceiverUpgradeable, OwnableUpgradeable, TimeUtil, ApiQueryClient {
    struct Item { address owner; uint startTime; }
    // Mapping from token ID to owner address
    mapping(uint256 => Item) public _owners;
    NFTClient nft;
    uint32[] private experiences;

    function setNFTClient(address _nft) public onlyOwner {
        nft = NFTClient(_nft);
    }

    function initialize() public initializer {
        __Ownable_init();
        experiences.push(7200);
        experiences.push(14400);
        experiences.push(25200);
        experiences.push(39600);
        experiences.push(57600);
        experiences.push(79200);
        experiences.push(104400);
        experiences.push(133200);
        experiences.push(165600);
        experiences.push(201600);
        experiences.push(241200);
        experiences.push(284400);
        experiences.push(331200);
        experiences.push(381600);
        experiences.push(435600);
        experiences.push(493200);
        experiences.push(554400);
        experiences.push(619200);
        experiences.push(687600);
        experiences.push(759600);
        experiences.push(835200);
        experiences.push(914400);
        experiences.push(997200);
        experiences.push(1083600);
        experiences.push(1173600);
        experiences.push(1267200);
        experiences.push(1364400);
        experiences.push(1465200);
        experiences.push(1569600);
        experiences.push(0);
    }

    // fixme: dev used only
    constructor() {
        initialize();
    }

    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        require(msg.sender == address(nft), "only the nft");
        operator;
        data;
        _owners[tokenId] = Item({owner: from, startTime: currentTime()});
        return this.onERC721Received.selector;
    }

    function claim(uint tokenId) public returns (bool) {
        require(msg.sender == _owners[tokenId].owner, "only self");
        // todo cul value
        address owner = _owners[tokenId].owner;

        // back the NFT
        // enum        Status  {   UNSTAKED, TRAINING, RAIDING, EXPLORING, HUNTING }
        require(nft.backFrom(1, owner, tokenId, uint16And32ToBytes(5, 200)) == true, "abnormal state");

        // update level
        handleTargetLevel(tokenId);
        // update local status
        _owners[tokenId] = Item({owner: address(0), startTime: 0});
        return true;
    }
    function handleTargetLevel(uint tokenId) internal {
        // the max level
        uint maxLevel = experiences.length;
        // 1 exp/s
        // uint allUnusedExp = (currentTime() - _owners[tokenId].startTime) * 1; fixme
        uint allUnusedExp = (currentTime() - _owners[tokenId].startTime) * 1000;
        (uint16 currentLevel, uint32 currentLvlProgress) = nft.getCurrentLevelAndLvlProgress(tokenId);
        require(currentLevel > 0, "invalid level");
        if (currentLevel < maxLevel) {
            uint16 targetLevel = currentLevel;
            uint32 targetLvlProgress = currentLvlProgress;
            for (uint index = 0; index < maxLevel; index++) {
                uint32 expCap = experiences[targetLevel - 1] - targetLvlProgress;
                // level up
                if (allUnusedExp >= expCap) {
                    targetLevel += 1;
                    allUnusedExp -= expCap;
                    targetLvlProgress = 0;
                } else {
                    // not up
                    targetLvlProgress = uint32(allUnusedExp);
                    break;
                }
                // get the max level
                if (targetLevel >= maxLevel) {
                    targetLevel = uint16(maxLevel);
                    targetLvlProgress = 0;
                    break;
                }
            }
            if (targetLevel > 0 && targetLevel <= maxLevel && targetLvlProgress < experiences[experiences.length - 2]) {
                nft.updateLevelAndLvlProgress(tokenId, targetLevel, targetLvlProgress);
            }
        }
    }

    function uint16And32ToBytes(uint16 sixteen, uint32 thirtyTw) internal pure returns (bytes memory data) {
        data = new bytes(6);
        bytes2 b2 = bytes2(sixteen);
        data[0] = b2[0];
        data[1] = b2[1];
        bytes4 b4 = bytes4(thirtyTw);
        data[2] = b4[0];
        data[3] = b4[1];
        data[4] = b4[2];
        data[5] = b4[3];
    }
    function getCurrentStatus(uint256 tokenId, uint mapId) external view override returns (StatusResult memory statusResult) {
        if (_owners[tokenId].owner == address(0)) {
            return StatusResult({ifHas: false, isDone: false, mapId: 0, startTime: 0, reward: 0});
        }
        mapId;
        (bool ifHas, bool isDone, uint startTime, uint reward) = (true, false, 0, 0);
        startTime = _owners[tokenId].startTime;
        statusResult = StatusResult({ifHas: ifHas, isDone: isDone, mapId: 0, startTime: startTime, reward: reward});
    }
}