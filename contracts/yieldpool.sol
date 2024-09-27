// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^4.8.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "hardhat/console.sol";

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function mint(address recipient, uint256 amount) external;

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ILending {
    function deposit(uint, uint) external returns(uint);
    function withdraw(uint) external returns(uint);
    function calculateCurrentRewards(uint) external view  returns(uint);
}

interface IStaking {

}

contract yieldpool is OwnableUpgradeable{
    IERC20 public usdtToken;
    ILending public lendingContract;

    IStaking public stakingContract;

    uint public lendingRatio;
    uint public stakingRatio;

    uint public minDeposit;
    uint public maxDeposit;

    function initialize(IERC20 addressUsdt, ILending _lendingContract, IStaking _stakingContract) external initializer {
        usdtToken = addressUsdt;
        lendingContract = _lendingContract;
        stakingContract = _stakingContract;
        lendingRatio = 100;
    }

    struct profile {
        uint lentAmount;
        uint stakedAmount;
        uint id;
    }

    mapping(address => profile) public profiles;

    function deposit(uint amount) public {
        usdtToken.transferFrom(msg.sender, address(this), amount);
        if(profiles[msg.sender].lentAmount==0){
            usdtToken.approve(address(lendingContract), (amount*lendingRatio)/100);
        uint id = lendingContract.deposit(0, (amount*lendingRatio)/100);
        profiles[msg.sender].id = id;
        }
        else{
            usdtToken.approve(address(lendingContract), (amount*lendingRatio)/100);
            lendingContract.deposit(profiles[msg.sender].id, (amount*lendingRatio)/100);
        }
        profiles[msg.sender].lentAmount += amount;
    }

    function withdraw() public {
        uint id = profiles[msg.sender].id;
        uint returned = lendingContract.withdraw(id);
        usdtToken.transfer(msg.sender, returned);
    }

    function viewReturns(address user) public view returns(uint){
        uint id = profiles[user].id;
        uint amount = lendingContract.calculateCurrentRewards(id);
        return amount;
    }
}