// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./utils/MathUtils.sol";

contract Monster is ERC721Upgradeable,OwnableUpgradeable,MathUtils{

    uint256 private constant         RAND_SIZE = 100;
    uint[]  _weightArrays = [80,90,98,100];
    uint256 public                   _totalSupply;
    
    using Counters for Counters.Counter;
    Counters.Counter private         _tokenCounter;
    
    mapping (address => bool)        _minters;
    mapping (uint256 => MonsterInfo) public _monsterInfos;
    mapping (uint256 => MonsterInfo) public _tokenInfos;
    mapping (uint256 => uint256)     public _weightMaps;
    mapping (address => uint256[])   public _ownerTokens;
    mapping (uint256 => uint8)       public tokenSet;

    CountInfo countInfo;

    struct MonsterInfo{
        uint8 level;
        string  name;
        uint256 weight;
    }

    struct MonsterCountInfo{
        uint8 level;
        string  name;
        uint256 count;
    }

    struct CountInfo{
        mapping (string => uint256) countMap;
    }

   constructor(){
       initialize();
   }

   modifier onlyMinter() {
        require(_minters[_msgSender()] == true, "Minter: caller is not the minter");
        _;
    }

   function initialize() internal initializer{
        __ERC721_init("BGC_NFT", "NFT2");
        __Ownable_init();
        initWeightMaps();
        initMonsterInfos();
   }

   function initWeightMaps() internal initializer{
        _weightMaps[80] = 1;
        _weightMaps[90] = 2;
        _weightMaps[98] = 3;
        _weightMaps[100] = 4;
   }

   function initMonsterInfos() internal initializer{
       _monsterInfos[1] = MonsterInfo({level:1,name:"N",weight:80});
       _monsterInfos[2] = MonsterInfo({level:2,name:"R",weight:90});
       _monsterInfos[3] = MonsterInfo({level:3,name:"SR",weight:98});
       _monsterInfos[4] = MonsterInfo({level:4,name:"SSR",weight:100});
   }

    
    function setMinter(address to,bool flag) public onlyOwner {
        _minters[to] = flag;
    }

    function mint(address to) public onlyMinter returns(uint256){
        //gen token
        _tokenCounter.increment();
        uint256 tokenId = _tokenCounter.current();

        _totalSupply++;
        
        _mint(to,tokenId);

        saveMonster(tokenId,getRandMonster());

        return tokenId;
    }

    function mintMany(address to,uint256 count) public onlyMinter{
        for(uint i = 0; i < count; i++){
            mint(to);
        }
    }

    function saveMonster(uint256 tokenId,MonsterInfo memory monsterInfo) internal{
        _tokenInfos[tokenId] = monsterInfo;
    }

    function getRandMonster() internal returns (MonsterInfo memory monsterInfo){
        uint rand = random(RAND_SIZE);
        uint256 index = 1;
        for(uint i=0; i<_weightArrays.length; i++){
            if(rand < _weightArrays[i]){
                index = _weightMaps[_weightArrays[i]];
                break;
            }
        }
        return _monsterInfos[index];
    }

    function getOwnerTokenInfos() public view returns (MonsterInfo[] memory res){
        uint256[] memory tokenIds = _ownerTokens[_msgSender()];
        res = new MonsterInfo[](tokenIds.length);
        for(uint16 i=0;i<tokenIds.length;i++){
            res[i] = _tokenInfos[tokenIds[i]];
        }
    }

    function getSumOwnerTokenInfos() public view returns (MonsterCountInfo[] memory res){
        uint256[] memory tokenIds = _ownerTokens[_msgSender()];
        MonsterCountInfo[] memory temp = new MonsterCountInfo[](tokenIds.length);
        uint16[] memory t = new uint16[](4);
        uint16 index = 0;
        for(uint16 i=0; i<tokenIds.length; i++){
            MonsterInfo memory info = _tokenInfos[tokenIds[i]];
            uint8 lvl = info.level-1;
            if(t[lvl] == 0){
                t[lvl] = 1;
                index++;
            }
            if(temp[lvl].level > 0){
                temp[lvl].count++;
            }else{
                temp[lvl] = MonsterCountInfo({level:info.level,name:info.name,count:1});
            }
        }
        res = new MonsterCountInfo[](index);
        for(uint256 i=0; i<index; i++){
            res[i] = temp[i];
        }
    }

     function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        from;
        if(to == address(0)) return;
        uint256 uid = uint256(keccak256(abi.encodePacked(to,tokenId)));
        if(tokenSet[uid] == 0){
            tokenSet[uid] = 1;
            _ownerTokens[to].push(tokenId);
        }
    } 

   
}