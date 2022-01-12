// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./utils/TimeUtil.sol";
import "./client/ISPClient.sol";
import "./client/ExplorerClient.sol";


interface ExplorerFactoryClient {
    function randomPop(uint rand) external returns (uint8 body, uint8 eyes, uint8 mouse, uint8 pigtail);
}

contract Explorer is ERC721Upgradeable, OwnableUpgradeable, TimeUtil {

    // tokenId counter
    using Counters for Counters.Counter;
    Counters.Counter    private _tokenIds;
    uint    public  totalSupply;

    /**** implementions */
    address public  explore;
    address public  hunt;
    address public  train;
    ExplorerFactoryClient explorerFactory;
    ISPClient isp;
    mapping (address => bool)   _minters;

    /**** action properties */
    mapping     (uint256 => Action) public activities;
    event       doAction(   uint    tokenId,    uint startTime, Status status);
    // token owner
    mapping     (address => uint256[]) public ownerTokens;

    mapping     (uint256 => uint8)     public tokenSet;

    /**** datas */
    // uint    constant        mintCost = 0.06 ether; fixme
    uint    constant    mintCost = 0 ether;
    uint32  constant    pct70 = type(uint16).max / 100 * 70;
    uint32  constant    pct71 = type(uint16).max / 100 * 71;
    uint32  constant    pct91 = type(uint16).max / 100 * 91;
    uint32  constant    pct99 = type(uint16).max / 100 * 99;
    uint32  constant    maxCount    =   10000;

    struct  MintCostItem    { uint count; uint cost; }
    MintCostItem[]      mintCostItems;
    mapping (uint => Explorers)     public  explorers;
    // mapping (uint => bool)          public  explorersCheckStore;
    bytes32 internal    entropySauce;
    // fixme: explore coupling properties
    uint8[] internal    minExploreLevel;

    // equip
    struct          EquipPct    {
        uint16  total;          uint16  lv_1;           uint16  lv_2;   uint16      lv_3;
    }
    struct          EquipPlace  {
        uint16      minEquipLevel;  uint16      equipCoolDown;  uint8       basicsValue;        uint        cost;
        EquipPct    helmEquipPct;   EquipPct    weaponEquipPct; EquipPct    clothesEquipPct;
    }
    EquipPlace[]            public  equipPlaceInfo;
    mapping (uint => uint)  public  lastEquipTime;
    uint    countPerTier    =   1; // the count of equip / tier
    uint    constant        theMaxCountPerTier  =   10;
    

    function setExplore(address newExplore) public onlyOwner {
        explore = newExplore;
        _minters[newExplore] = true;
    }
    function setTrain(address newTrain) public onlyOwner {
        train = newTrain;
        _minters[newTrain] = true;
    }
    function setMinter(address addr, bool isMinter) public onlyOwner {
        _minters[addr] = isMinter;
    }
    function setHunt(address account) public onlyOwner {
        hunt = account;
        _minters[account] = true;
    }
    function setISPClient(address _isp) public onlyOwner {
        isp = ISPClient(_isp);
    }
    function setExplorerFactoryClient(address _explorerFactory) public onlyOwner {
        explorerFactory = ExplorerFactoryClient(_explorerFactory);
    }

    function initialize() public initializer {
        __ERC721_init("MyNFT_V1", "NT1");
        __Ownable_init();
        mintCostItems.push(MintCostItem({count: 2500,   cost: 4  ether}));
        mintCostItems.push(MintCostItem({count: 3000,   cost: 8  ether}));
        mintCostItems.push(MintCostItem({count: 4000,   cost: 16 ether}));
        mintCostItems.push(MintCostItem({count: 5000,   cost: 24 ether}));
        mintCostItems.push(MintCostItem({count: 6000,   cost: 32 ether}));
        mintCostItems.push(MintCostItem({count: 7000,   cost: 40 ether}));
        mintCostItems.push(MintCostItem({count: 8000,   cost: 48 ether}));
        mintCostItems.push(MintCostItem({count: 9000,   cost: 56 ether}));
        mintCostItems.push(MintCostItem({count: 10000,  cost: 64 ether}));
        minExploreLevel.push(1);
        minExploreLevel.push(5);
        minExploreLevel.push(10);
        equipPlaceInfo.push(EquipPlace({
            minEquipLevel:      1,   cost: 0,        equipCoolDown: 600,    basicsValue: 0,
            helmEquipPct:       EquipPct({total: 10000, lv_1: 8000, lv_2: 1500, lv_3: 500}),
            weaponEquipPct:     EquipPct({total: 10000, lv_1: 8000, lv_2: 1500, lv_3: 500}),
            clothesEquipPct:    EquipPct({total: 10000, lv_1: 8000, lv_2: 1500, lv_3: 500})
        }));
        equipPlaceInfo.push(EquipPlace({
            minEquipLevel:      5,   cost: 0,        equipCoolDown: 600,    basicsValue: 1,
            helmEquipPct:       EquipPct({total: 10000, lv_1: 8500, lv_2: 1000, lv_3: 500}),
            weaponEquipPct:     EquipPct({total: 10000, lv_1: 8500, lv_2: 1000, lv_3: 500}),
            clothesEquipPct:    EquipPct({total: 10000, lv_1: 8500, lv_2: 1000, lv_3: 500})
        }));
        equipPlaceInfo.push(EquipPlace({
            minEquipLevel:      10,  cost: 0,        equipCoolDown: 600,    basicsValue: 1,
            helmEquipPct:       EquipPct({total: 10000, lv_1: 8500, lv_2: 1400, lv_3: 100}),
            weaponEquipPct:     EquipPct({total: 10000, lv_1: 8500, lv_2: 1400, lv_3: 100}),
            clothesEquipPct:    EquipPct({total: 10000, lv_1: 8500, lv_2: 1400, lv_3: 100})
        }));
    }

    // fixme: dev used only
    constructor() {
        initialize();
    }

    function getOwnerTokens(address addr) public view returns (uint256[] memory) {
        return ownerTokens[addr];
    }

    /******************* hook *******************/
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override {
        if (to == address(0)) return;
        uint256 uid = uint256(keccak256(abi.encodePacked(to,tokenId)));
        if (tokenSet[uid] == 0) {
            tokenSet[uid] = 1;
            ownerTokens[to].push(tokenId);
        }
        from;
    }

    /******************* modifier *******************/
    modifier onlyMinter() {
        require(_minters[_msgSender()] == true, "Minter: caller is not the minter");
        _;
        // We'll use the last caller hash to add entropy to next caller
        entropySauce = keccak256(abi.encodePacked(_msgSender(), block.coinbase));
    }
    modifier onlySelf(uint tokenId) {
        require(ownerOf(tokenId) == _msgSender(), "only self");
        _;
    }
    modifier onlyUnstate(uint tokenId) {
        require(activities[tokenId].status == Status.UNSTAKED, "abnormal initial state");
        _;
    }

    /******************* mint *******************/
    // mintType: true: ether, false: isps
    function getMintTypeAndCost() public view returns (bool mintType, uint amount) {
        mintType = totalSupply < 2000;
        if (mintType) {
            amount = mintCost;
        } else {
            for (uint8 index = 0; index < mintCostItems.length; index++) {
                if (totalSupply < mintCostItems[index].count) {
                    amount = mintCostItems[index].cost;
                    break;
                }
            }
        }
    }

    // mint nft
    function mint(address addr) public payable returns (uint) {
        require(totalSupply < maxCount, "");
        (bool mintType, uint amount) = getMintTypeAndCost();
        if (!mintType) {
            isp.rateBurn(_msgSender(), amount);
        } else {
            // use ether
            require(msg.value == mintCost, "need give ether");
        }
        _tokenIds.increment();
        uint newTokenId = _tokenIds.current();
        _safeMint(addr, newTokenId);
        // There is no possibility of overflow
        totalSupply += 1;
        initExplorer(newTokenId);
        return newTokenId;
    }
    // init nft
    function initExplorer(uint tokenId) internal {
        (uint8 body, uint8 eyes, uint8 mouse, uint8 pigtail) = explorerFactory.randomPop(_rand(uint32(tokenId)));
        // set the properties
        explorers[tokenId] = Explorers({
            body: body, eyes: eyes, mouse: mouse, pigtail: pigtail,
            helm: 0, weapon: 0, clothes: 0, feet: 0, back: 0,
            ability: 5, level: 1, lvlProgress: 0//, lvlTotalValue: 0
        });
        require(explorers[tokenId].body != 0, "Try again later");
    }

    function burn(uint tokenId) public onlyOwner returns (bool) {
        require(_exists(tokenId), "not exists");
        _burn(tokenId);
        // There is no possibility of overflow
        totalSupply -= 1;
        return true;
    }

    /******************* equip *******************/
    // part 0: helm, 1: weapon, 2: clothes
    function equip(uint tokenId, uint mapId, uint part) public onlySelf(tokenId) onlyUnstate(tokenId) returns (uint16 increment) {
        // check min level
        EquipPlace memory equipPlace = equipPlaceInfo[mapId - 1];
        require(equipPlace.minEquipLevel > 0, "abnormal mapId");
        require(explorers[tokenId].level >= equipPlace.minEquipLevel, "Insufficient level");
        // check cd
        uint diff = currentTime() - lastEquipTime[tokenId];
        require(diff > equipPlace.equipCoolDown, "cool down not enough");
        if (equipPlace.cost > 0) {
            isp.rateBurn(_msgSender(), equipPlace.cost);
        }
        // give equip
        EquipPct memory epct = part == 0 ? equipPlace.helmEquipPct : part == 1 ? equipPlace.weaponEquipPct : equipPlace.clothesEquipPct;
        uint rand = _rand(uint32(mapId));
        uint random = rand % epct.total;
        uint8 power;
        if (random > epct.lv_1 + epct.lv_2 && epct.lv_3 > 0) {
            power = equipPlace.basicsValue + 3;
        } else if (random > epct.lv_1 && epct.lv_2 > 0) {
            power = equipPlace.basicsValue + 2;
        } else {
            power = equipPlace.basicsValue + 1;
        }
        uint8 item = uint8((random % countPerTier) + ((power - 1) * theMaxCountPerTier) + 1);
        part == 0 ? explorers[tokenId].helm = item : part == 1 ? explorers[tokenId].weapon = item : explorers[tokenId].clothes = item;
        // update cd
        lastEquipTime[tokenId] = currentTime();
        // update ability
        handleAbility(tokenId);
        increment = uint16((item / theMaxCountPerTier) + 1);
    }
    function setCountPerTier(uint count) public onlyOwner {
        countPerTier = count;
    }
    function handleAbility(uint tokenId) internal {
        uint16 helmAbility;
        uint16 weaponAbility;
        uint16 clothesAbility;
        helmAbility = explorers[tokenId].helm == 0 ? 0 : uint16((explorers[tokenId].helm / theMaxCountPerTier) + 1);
        weaponAbility = explorers[tokenId].weapon == 0 ? 0 : uint16((explorers[tokenId].weapon / theMaxCountPerTier) + 1);
        clothesAbility = explorers[tokenId].clothes == 0 ? 0 : uint16((explorers[tokenId].clothes / theMaxCountPerTier) + 1);
        explorers[tokenId].ability = helmAbility + weaponAbility + clothesAbility;
    }

    /******************* external funs *******************/
    function backFrom(uint8 status, address to, uint256 tokenId, bytes memory data) public onlyMinter returns (bool) {
        // check status
        require(uint8(activities[tokenId].status) == status, "abnormal state");
        require(activities[tokenId].owner == to, "abnormal owner");
        // handle train
        if (uint8(Status.TRAINING) == status) {
            (uint16 level, uint32 lvlProgress) = toUint16And32(data);
            if (level >= 30) {
                level = 30;
                lvlProgress = 0;
            }
            explorers[tokenId].level = level;
            explorers[tokenId].lvlProgress = lvlProgress;
        }
        activities[tokenId] = Action({owner: address(0), startTime: 0, status: Status.UNSTAKED});
        // send nft
        safeTransferFrom(_msgSender(), to, tokenId);
        return true;
    }
    function backFrom(uint8 status, address to, uint256 tokenId) public onlyMinter returns (bool) {
        return backFrom(status, to, tokenId, "");
    }
    function updateLevelAndLvlProgress(uint256 tokenId, uint16 targetLevel, uint32 targetLvlProgress) external onlyMinter {
        explorers[tokenId].level = targetLevel;
        explorers[tokenId].lvlProgress = targetLvlProgress;
    }
    function getCurrentLevelAndLvlProgress(uint256 tokenId) external view returns (uint16 level, uint32 lvlProgress) {
        level = explorers[tokenId].level;
        lvlProgress = explorers[tokenId].lvlProgress;
    }
    
    /******************* actions *******************/
    function goExplore(uint tokenId, uint mapId) public onlySelf(tokenId) onlyUnstate(tokenId) returns (bool) {
        // check min level
        require(minExploreLevel[mapId - 1] > 0, "abnormal mapId");
        require(explorers[tokenId].level >= minExploreLevel[mapId - 1], "Insufficient level");
        activities[tokenId] = Action({owner: _msgSender(), startTime: currentTime(), status: Status.EXPLORING});
        safeTransferFrom(_msgSender(), explore, tokenId, toBytes(mapId));
        emit doAction(tokenId, currentTime(), Status.EXPLORING);
        return true;
    }

    function goHunting(uint256 tokenId) public {
        goWorking(tokenId,Status.HUNTING);
    }


    function returnBack(uint256 tokenId) public {
        require(activities[tokenId].status != Status.UNSTAKED, "can not be UNSTAKED");
        require(_isApprovedOrOwner(_msgSender(), tokenId) || _minters[_msgSender()], "not approved");
        _safeTransfer(ownerOf(tokenId), activities[tokenId].owner, tokenId, "");
        activities[tokenId] = Action({owner: address(0), startTime: 0, status: Status.UNSTAKED});
        emit doAction(tokenId, currentTime(), Status.UNSTAKED);
    }

    function goWorking(uint256 tokenId,Status status) internal {
        require(activities[tokenId].status == Status.UNSTAKED, "e is working");
        require(status != Status.UNSTAKED, "status exists");
        require(_isApprovedOrOwner(_msgSender(), tokenId) || _minters[_msgSender()], "not approved");
        activities[tokenId] = Action({owner: ownerOf(tokenId), startTime: currentTime(), status: status});
        _safeTransfer(ownerOf(tokenId), hunt, tokenId, "");
        emit doAction(tokenId, currentTime(), status);
    }

    function isWorking(uint256 tokenId) public view returns (bool){
        return activities[tokenId].status != Status.UNSTAKED;
    }

    function isHunting(uint256 tokenId)public view returns (bool){
        return activities[tokenId].status == Status.HUNTING;
    }

    function goTrain(uint tokenId) public onlySelf(tokenId) onlyUnstate(tokenId) returns (bool) {
        require(explorers[tokenId].level < 30, "already max level");
        activities[tokenId] = Action({owner: _msgSender(), startTime: currentTime(), status: Status.TRAINING});
        safeTransferFrom(_msgSender(), train, tokenId);
        emit doAction(tokenId, currentTime(), Status.TRAINING);
        return true;
    }

    /******************* utils *******************/
    function _rand(uint32 salt) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(msg.sender, currentTime(), block.difficulty, block.number, entropySauce, salt)));
    }
    function _randomize(uint256 rand, string memory val, uint256 spicy) internal pure returns (uint256) {
        return uint256(keccak256(abi.encode(rand, val, spicy)));
    }
    function toBytes(uint256 x) internal pure returns (bytes memory b) {
        b = new bytes(32);
        unchecked {
            assembly { mstore(add(b, 32), x) }
        }
    }
    function toUint16And32(bytes memory data) internal pure returns (uint16 sixteen, uint32 thirtyTwo) {
        require(data.length == 6, "abnormal length");
        bytes memory b2 = new bytes(2);
        b2[0] = data[0];
        b2[1] = data[1];
        sixteen = uint16(bytesToUint(b2));
        bytes memory b4 = new bytes(4);
        b4[0] = data[2];
        b4[1] = data[3];
        b4[2] = data[4];
        b4[3] = data[5];
        thirtyTwo = uint32(bytesToUint(b4));
    }
    function bytesToUint(bytes memory b) internal pure returns (uint256 number) {
        for(uint i = 0; i < b.length; i++) {
            number = number + uint8(b[i])*(2**(8*(b.length-(i+1))));
        }
    }

}