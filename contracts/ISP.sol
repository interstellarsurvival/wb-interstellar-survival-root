// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract ISP is ERC20Upgradeable, OwnableUpgradeable {
    mapping(address => bool) private _minters;

    function initialize() public initializer {
        __ERC20_init("MyToken_V1", "TK1");
        __Ownable_init();
    }

    // fixme: dev used only
    constructor() {
        initialize();
    }

    function setMinter(address addr, bool isMinter) public onlyOwner {
        _minters[addr] = isMinter;
    }

    /******************* modifier *******************/
    modifier onlyMinter() {
        require(_minters[_msgSender()] == true, "Minter: caller is not the minter");
        _;
    }

    function mint(address account, uint256 amount) public onlyMinter {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public onlyMinter {
        _burn(account, amount);
    }

    // fixme: rate not impl
    function rateBurn(address account, uint256 amount) public onlyMinter {
        _burn(account, amount);
    }
}