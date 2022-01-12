// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/TimeUtil.sol";
import "./utils/MathUtils.sol";
import "./client/ISPClient.sol";
import "./client/ExplorerClient.sol";
import "./client/MonsterClient.sol";
import "./client/ApiQueryClient.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";


contract Hunt is OwnableUpgradeable, IERC721ReceiverUpgradeable, TimeUtil, MathUtils, ApiQueryClient {

    ExplorerClient                  explorer ;
    ISPClient                       isp ;
    MonsterClient                   monster ;
    ApiQueryClient                  api ;

    uint[]  _ispWeightArrays     = [6000,8000,9500,10000];
    uint[]  _monsterWeightArrays = [8000,9000,9800,10000];
    uint256 constant WEIGHT_SIZE = 10000;
    uint256 constant NULL        = 0;

     //enum
    enum    MAPS                    {NULL,FOREST,FOG,SPACECRAFT}
    enum    ACTIONS                 {HUNT,RECALL}


    //mappings
    mapping (MAPS    => MapConfig)  public _mapConfig;
    mapping (uint256 => uint256)    public _costPool;
    mapping (uint256 => uint256)    public _rewardPool;
    mapping (uint256 => MapInfo)    public _tokenPool;
    mapping (uint256 => uint256)    public _ispReturnConfig;
    mapping (uint256 => uint256)    public _monsterReturnConfig;


    //events
    event  doAction(address to, uint256 tokenId, uint startTime, MAPS MAPS, ACTIONS action);

    struct MapConfig {
        string   name;
        uint8    level;
        uint8    roleId;
        uint256  workingTime;
        uint256  isp;
    }

    struct MapInfo {
        MAPS map;
        uint256 startTime;
        address owner;
    }

    constructor() {
        initialize();
    }

    function initialize() public initializer {
        __Ownable_init();
        initMapConfig();
        initIspReturnConfig();
        initMonsterReturnConfig();
    }

    function initMapConfig() internal initializer{
        _mapConfig[MAPS.FOREST] = MapConfig({name: "forest", level: 1, roleId: 1, workingTime: 0, isp: 10});
        _mapConfig[MAPS.FOG] = MapConfig({name: "fog", level: 5, roleId:1, workingTime: 2880, isp: 50});
        _mapConfig[MAPS.SPACECRAFT] = MapConfig({name: "spaceCraft", level: 10, roleId:1, workingTime: 2880, isp: 100});
    }

    function initIspReturnConfig() internal initializer{
        _ispReturnConfig[6000] = 5;
        _ispReturnConfig[8000] = 6;
        _ispReturnConfig[9500] = 7;
        _ispReturnConfig[10000] = 8;
    }

    function initMonsterReturnConfig() internal initializer{
        _monsterReturnConfig[8000] = 0;
        _monsterReturnConfig[9000] = 1;
        _monsterReturnConfig[9800] = 2;
        _monsterReturnConfig[10000] = 3;
    }

    function setExplorer(address explorerAddress) public onlyOwner{
        explorer = ExplorerClient(explorerAddress);
    }

    function setIsp(address ispAddress) public onlyOwner{
        isp = ISPClient(ispAddress);
    }

    function setMonster(address monsterAddress) public onlyOwner{
        monster = MonsterClient(monsterAddress);
    }

    function setApi(address apiAddress) public onlyOwner{
        api = ApiQueryClient(apiAddress);
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
        require(msg.sender == address(explorer) || msg.sender == address(monster), "only the nft");
        operator;
        data;
        if(msg.sender == address(explorer)){
            _tokenPool[tokenId].owner = from;
        }

        return this.onERC721Received.selector;
    }


    //hunt for monster with explorer in MAPS
    //@param address
    //@param tokenId
    //@param MAPS
    function hunt(uint256 tokenId,uint8 mapId) public {
        address to = _msgSender();
        // to = _msgSender();
        MAPS map = MAPS(mapId);
        //verify tokenId
        require(explorer.ownerOf(tokenId) == to, "only self");

        //verify role status
        require(explorer.isWorking(tokenId) == false, "is working");

        //load initConfig
        MapConfig memory mapConfig = _mapConfig[map];

        //TODO verify role level of map
        Explorers memory es = explorer.explorers(tokenId);
        require(es.level >= mapConfig.level,"level limit");

        //计算ISP扣除 fixme
        isp.rateBurn(to, mapConfig.isp);

        //update role status, startTime, owner
        explorer.goHunting(tokenId);

        _tokenPool[tokenId] = MapInfo({map:map,owner:to,startTime:currentTime()});

        //record action
        emit doAction(_msgSender(), tokenId, currentTime(), map, ACTIONS.HUNT);
    }


    //recall explorer from hunting
    function recall(uint256 tokenId) public{
        //verify status = hunt

        //get role config
        MapInfo memory mapInfo = _tokenPool[tokenId];
        require(mapInfo.map != MAPS.NULL, "area error");
        //verify tokenId
        require(mapInfo.owner == _msgSender(), "only self");

        //load initConfig
        MapConfig memory mapConfig = _mapConfig[mapInfo.map];
        //verify map time
        uint256 sec = currentTime() - mapInfo.startTime;
        require(sec > mapConfig.workingTime, "time not up");

        //calculate for monster count
        uint256 count = getMonsterCount();

        //if monster > 0
        if(count > 0){

            //mint monster
            monster.mintMany(_msgSender(), count);
            //update role status,startTime,woner
            explorer.returnBack(tokenId);
        }else{
            //return ISP if fail to get monster
            isp.mint(_msgSender(), getISPReturnCount(mapConfig.isp));
        }

        _tokenPool[tokenId].map = MAPS.NULL;

        //record action
        emit doAction(_msgSender(), tokenId, currentTime(), mapInfo.map, ACTIONS.RECALL);

    }


     //calculate monster count
    function getMonsterCount() internal returns (uint256){
        uint256 res = 0;
        uint256 rand = random(WEIGHT_SIZE);
        for (uint i = 0; i < _monsterWeightArrays.length; i++) {
            if(rand < _monsterWeightArrays[i]){
                res = _monsterReturnConfig[_monsterWeightArrays[i]];
                break;
            }
        }
        return res;
    }

    //calculate ISP return
    function getISPReturnCount(uint256 srcIsp) internal returns (uint256){
        uint256 res = 0;
        uint256 rand = random(WEIGHT_SIZE);
        for(uint i = 0; i < _ispWeightArrays.length; i++){
            if(rand < _ispWeightArrays[i]){
                res = _ispReturnConfig[_ispWeightArrays[i]];
                break;
            }
        }

        return res * srcIsp / 10;
    }

    function getMapConfigInfo() public view returns(MapConfig[] memory res){
        res = new MapConfig[](3);
        res[0] = _mapConfig[MAPS.FOREST];
        res[1] = _mapConfig[MAPS.FOG];
        res[2] = _mapConfig[MAPS.SPACECRAFT];
    }

    function getCurrentStatus(uint256 tokenId, uint mapId) public view returns (StatusResult memory statusResult) {
        (bool ifHas, bool isDone, uint8 _mapId, uint startTime, uint reward) = (false, false, 0, 0, 0);
        MapInfo memory mapInfo = _tokenPool[tokenId];
        if (mapId > 0) {
            ifHas = mapInfo.map == MAPS(mapId);
        } else {
            ifHas = mapInfo.map != MAPS.NULL;
        }
        MapConfig memory mapConfig = _mapConfig[mapInfo.map];
        isDone = (mapConfig.workingTime + mapInfo.startTime) > currentTime();
        startTime = mapInfo.startTime;
        reward;
        _mapId = uint8(mapInfo.map);
        statusResult = StatusResult({ifHas: ifHas, isDone: isDone, mapId: _mapId, startTime: startTime, reward: reward});
    }
}