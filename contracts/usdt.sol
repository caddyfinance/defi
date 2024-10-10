// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";


contract USDT is ERC20Burnable{
    constructor()
        ERC20("USDT Fake", "USDTf")
    {
        
    }
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}