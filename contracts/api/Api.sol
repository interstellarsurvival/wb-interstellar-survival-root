// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../client/ExplorerClient.sol";
import "../client/ApiQueryClient.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Api is Ownable {

    ExplorerClient public explorer;
    ApiQueryClient public train;
    ApiQueryClient public explore;
    ApiQueryClient public hunt;

    struct Item {
        uint8   status;     bool    isDone; uint8   mapId;      uint8       occupation; // 0: explorer
        uint    startTime;  uint    reward; uint    tokenId;    Explorers   explorer;
    }
    struct StatisticsInfo {
        uint16 heroes; uint16 huntDone; uint16 raidDone; uint unclaimed;
    }

    function setExplorer(address explorerAddress) public onlyOwner{
        explorer = ExplorerClient(explorerAddress);
    }
    function setTrain(address trainAddress) public onlyOwner{
        train = ApiQueryClient(trainAddress);
    }
    function setExplore(address exploreAddress) public onlyOwner{
        explore = ApiQueryClient(exploreAddress);
    }
    function setHunt(address huntAddress) public onlyOwner{
        hunt = ApiQueryClient(huntAddress);
    }

    function queryByTokenId(uint tokenId) public view returns (Item memory items) {
        Action memory action = explorer.activities(tokenId);
        return getItem(action.status, tokenId, 0);
    }

    function queryByStatus(bool isAll, Status status) public view returns (Item[] memory items, StatisticsInfo memory statisticsInfo) {
        address sender = _msgSender();
        // 1.Query the possessed NFT list(Includes the ones that have been sold)
        uint256[] memory tokenIds = explorer.getOwnerTokens(sender);
        require(tokenIds.length > 0, "nothing");
        Item[] memory temp = new Item[](tokenIds.length);
        uint i = 0;
        Status _status = status;

        if (isAll) {
            for (uint256 index = 0; index < tokenIds.length; index++) {
                Action memory action = explorer.activities(tokenIds[index]);
                if (action.owner == sender || explorer.ownerOf(tokenIds[index]) == sender) {
                    // 2.Assemble other parameters
                    _status = action.status;
                    temp[i] = getItem(_status, tokenIds[index], 0);
                    i++;
                }
            }
        } else {
            for (uint256 index = 0; index < tokenIds.length; index++) {
                Action memory action = explorer.activities(tokenIds[index]);
                if ((action.owner == sender || explorer.ownerOf(tokenIds[index]) == sender) && action.status == status) {
                    // 2.Assemble other parameters
                    temp[i] = getItem(status, tokenIds[index], 0);
                    i++;
                }
            }
        }

        items = new Item[](i);
        (uint16 heroes, uint16 huntDone, uint16 raidDone, uint unclaimed) = (uint16(i), 0, 0, 0);
        for(uint256 index = 0; index < i; index++){
            items[index] = temp[index];
            uint8 _statusTemp = temp[index].status;
            if (_statusTemp == uint8(Status.HUNTING)) {
                if (temp[index].isDone) huntDone++;
            } else if (_statusTemp == uint8(Status.RAIDING)) {
                if (temp[index].isDone) raidDone++;
            } else if (_statusTemp == uint8(Status.EXPLORING)) {
                unclaimed += temp[index].reward;
            }
        }
        statisticsInfo = StatisticsInfo({heroes: heroes, huntDone: huntDone, raidDone: raidDone, unclaimed: unclaimed});
    }
    function queryByMapId(Status status, uint mapId) public view returns (Item[] memory items) {
        address sender = _msgSender();
        // 1.Query the possessed NFT list(Includes the ones that have been sold)
        uint256[] memory tokenIds = explorer.getOwnerTokens(sender);
        require(tokenIds.length > 0, "nothing");
        Item[] memory temp = new Item[](tokenIds.length);
        uint i = 0;
        for (uint256 index = 0; index < tokenIds.length; index++) {
            Action memory action = explorer.activities(tokenIds[index]);
            if ((action.owner == sender || explorer.ownerOf(tokenIds[index]) == sender) && action.status == status) {
                // 2.Assemble other parameters
                temp[i] = getItem(status, tokenIds[index], mapId);
                i++;
            }
        }

        items = new Item[](i);
        for(uint256 index = 0; index < i; index++){
            items[index] = temp[index];
        }
    }

    function getItem(Status status, uint tokenId, uint mapId) internal view returns (Item memory item) {
        Explorers memory e = explorer.explorers(tokenId);
        require(e.body > 0, "API: operator query for nonexistent token");
        item = Item({
            isDone: false, occupation: 0, status: uint8(status), startTime: 0, reward: 0,
            mapId: 0, tokenId: tokenId, explorer: e
        });
        StatusResult memory statusResult;
        if (status == Status.TRAINING) {
            statusResult = train.getCurrentStatus(tokenId, mapId);
        } else if (status == Status.RAIDING) {
            return item;
        } else if (status == Status.EXPLORING) {
            statusResult = explore.getCurrentStatus(tokenId, mapId);
        } else if (status == Status.HUNTING) {
            statusResult = hunt.getCurrentStatus(tokenId, mapId);
        }
        if (!statusResult.ifHas) return item;
        item.isDone = statusResult.isDone;
        item.startTime = statusResult.startTime;
        item.reward = statusResult.reward;
        item.mapId = statusResult.mapId;
    }

}