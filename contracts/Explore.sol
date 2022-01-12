// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./utils/TimeUtil.sol";
import "./client/ISPClient.sol";
import "./client/ApiQueryClient.sol";

interface NFTClient {
    function backFrom(uint8 status, address to, uint256 tokenId) external returns (bool);
}

contract Explore is IERC721ReceiverUpgradeable, OwnableUpgradeable, TimeUtil, ApiQueryClient {
    struct Item { address owner; uint startTime; uint mapId; }
    // Mapping from token ID to owner address
    mapping(uint256 => Item) public _owners;
    NFTClient public nft;
    ISPClient public isp;
    // uint constant coolDown = 7200; fixme
    uint constant coolDown = 60;

    function setNFTClient(address _nft) public onlyOwner {
        nft = NFTClient(_nft);
    }
    function setISPClient(address _isp) public onlyOwner {
        isp = ISPClient(_isp);
    }

    function initialize() public initializer {
        __Ownable_init();
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
        _owners[tokenId] = Item({owner: from, startTime: currentTime(), mapId: bytesToUint(data)});
        return this.onERC721Received.selector;
    }

    function claim(uint tokenId) public returns (bool) {
        require(msg.sender == _owners[tokenId].owner, "only self");
        uint diff = currentTime() - _owners[tokenId].startTime;
        require(diff > 0, "invalid time");
        address owner = _owners[tokenId].owner;
        uint mapId = _owners[tokenId].mapId;
        // update local time
        _owners[tokenId].startTime = currentTime();

        // send erc20
        isp.mint(owner, diff * getEfficacy() * mapId / 600);
        return true;
    }
    function recall(uint tokenId) public returns (bool) {
        require(msg.sender == _owners[tokenId].owner, "only self");
        uint startTime = _owners[tokenId].startTime;
        // check cd
        uint diff = currentTime() - startTime;
        require(diff > coolDown, "cool down not enough");
        address owner = _owners[tokenId].owner;
        uint mapId = _owners[tokenId].mapId;
        // update local status
        _owners[tokenId] = Item({owner: address(0), startTime: 0, mapId: 0});

        // back the NFT
        // enum        Status  {   UNSTAKED, TRAINING, RAIDING, EXPLORING, HUNTING }
        require(nft.backFrom(3, owner, tokenId) == true, "abnormal state");
        // send erc20
        isp.mint(owner, diff * getEfficacy() * mapId / 600);
        return true;
    }
    function getEfficacy() internal pure returns (uint) {
        return 1 ether;
    }
    function bytesToUint(bytes memory b) internal pure returns (uint256 number) {
        for(uint i = 0; i < b.length; i++) {
            number = number + uint8(b[i])*(2**(8*(b.length-(i+1))));
        }
    }
    function getCurrentStatus(uint256 tokenId, uint mapId) external view returns (StatusResult memory statusResult) {
        if (_owners[tokenId].owner == address(0) || (mapId > 0 && _owners[tokenId].mapId != mapId)) {
            return StatusResult({ifHas: false, isDone: false, mapId: 0, startTime: 0, reward: 0});
        }
        (bool ifHas, uint8 _mapId, uint startTime, uint reward) = (true, 0, 0, 0);
        startTime = _owners[tokenId].startTime;
        _mapId = uint8(_owners[tokenId].mapId);
        uint diff = currentTime() - startTime;
        reward = diff * getEfficacy() * _mapId / 600;
        statusResult = StatusResult({ifHas: ifHas, isDone: false, mapId: _mapId, startTime: startTime, reward: reward});
    }
}