// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

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

contract Lending is OwnableUpgradeable{
    address public admin;
    uint public lendingCounter;
    uint public rate;

    IERC20 public usdtToken;

    uint public cycleDuration;

    struct info {
        address owner;
        uint amount;
        uint unrealisedRewards;
        uint timestamp;
    }

    mapping(uint => info) public lentInfo;

    modifier onlyAdmin() {
        require(msg.sender == admin, "onlyAdmin");
        _;
    }

    function initialize(IERC20 addressUsdt, address _admin, uint _cycleDuration, uint _rate) external initializer{
        lendingCounter = 1;
        admin = _admin;
        usdtToken = addressUsdt;
        cycleDuration = _cycleDuration;
        rate = _rate;
    }

     function deposit(uint id, uint amount) external returns(uint){
        uint timeNow = block.timestamp;
        uint returnedId;
        if (id == 0) {
            lentInfo[lendingCounter] = info(msg.sender, amount, 0, timeNow);
            returnedId = lendingCounter;
            lendingCounter++;
        } else {
            info memory x = lentInfo[id];
            lentInfo[id].unrealisedRewards +=
                (x.amount * rate * timeNow - x.timestamp) /
                (cycleDuration * 100);
            lentInfo[id].amount += amount;
            lentInfo[id].timestamp = timeNow;
            returnedId = id;
        }
        usdtToken.transferFrom(msg.sender, admin, amount);
        return returnedId;
    }

    function withdraw(uint id) external returns(uint){
        uint timeNow = block.timestamp;
        address recipient = lentInfo[id].owner;
        require(msg.sender == recipient, "restricted");
        uint totalAmount = calculateRewards(id, timeNow);
        lentInfo[id].timestamp = timeNow;
        lentInfo[id].unrealisedRewards = 0;
        usdtToken.mint(recipient, totalAmount);
        return totalAmount;
    }
    
    function calculateRewards(uint id, uint timestamp) public view  returns(uint){
        info memory x = lentInfo[id];
        
        return (x.unrealisedRewards +((timestamp - x.timestamp)/cycleDuration)*((x.amount * rate)/100));
    }

    function calculateCurrentRewards(uint id) public view  returns(uint){
        info memory x = lentInfo[id];
        
        return (x.unrealisedRewards +((block.timestamp - x.timestamp)/cycleDuration)*((x.amount * rate)/100));
    }



    function withdrawFunds(uint id) external {
         uint timeNow = block.timestamp;
        address recipient = lentInfo[id].owner;
        require(msg.sender == recipient, "restricted");
        uint totalAmount = lentInfo[id].amount+ calculateRewards(id, timeNow);
        lentInfo[id].timestamp = timeNow;
        lentInfo[id].unrealisedRewards = 0;
        lentInfo[id].amount = 0;
        usdtToken.mint(recipient, totalAmount);
    }
}