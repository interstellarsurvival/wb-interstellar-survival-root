// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract ExplorerFactory is OwnableUpgradeable {
    // uint16  constant            private totalCount = 10000; fixme
    uint16  constant            private totalCount = 100;
    uint16  private             alreadyMintCount;
    mapping (address => bool)   private _minters;

    Item[totalCount] private pool;

    struct Item {
        uint8   body;           uint8   eyes;       uint8   mouse;          uint8   pigtail;
        bool    status; /** alreday mint mark, true: yes */                 uint16  pointIndex;
    }

    function setMinter(address addr, bool isMinter) public onlyOwner {
        _minters[addr] = isMinter;
    }

    function initialize() public initializer {
        __Ownable_init();
    }
    // fixme: dev used only
    constructor() {
        initialize();
    }

    /******************* modifier *******************/
    modifier onlyMinter() {
        require(_minters[_msgSender()] == true, "Minter: caller is not the minter");
        _;
    }

    function pushItem(uint8 body, uint8 eyes, uint8 mouse, uint8 pigtail) public onlyOwner {
        // pool.push(Item({body: body, eyes: eyes, mouse: mouse, pigtail: pigtail, status: false, pointIndex: 0})); fixme
        for (uint index = 0; index < totalCount; index++) {
            pool[index] = Item({body: body++, eyes: eyes++, mouse: mouse++, pigtail: pigtail++, status: false, pointIndex: 0});
        }
    }

    function randomPop(uint rand) public onlyMinter returns (uint8 body, uint8 eyes, uint8 mouse, uint8 pigtail) {
        require(pool.length == totalCount, "init not done");
        require(totalCount > alreadyMintCount, "mint done");
        uint index = rand % (totalCount - alreadyMintCount);
        uint pointIndex = index;
        if (pool[index].status) {
            pointIndex = pool[index].pointIndex;
        }
        // dont change this sort, because maybe dead loop
        pool[index].pointIndex = getTheLast();
        pool[pointIndex].status = true;

        alreadyMintCount += 1;
        body = pool[pointIndex].body;
        eyes = pool[pointIndex].eyes;
        mouse = pool[pointIndex].mouse;
        pigtail = pool[pointIndex].pigtail;
    }
    function getTheLast() internal view returns (uint16 last) {
        last = totalCount - alreadyMintCount - 1;
        if (pool[last].pointIndex > 0) {
            last = pool[last].pointIndex;
        }
    }
}