// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./SafeMath.sol";
import "./DSMath.sol";
import "./IERC20.sol";
import "./Ownable.sol";

contract Farm is DSMath, Ownable {
    
    using SafeMath for uint;
    
    uint constant PERCENT10 = 10 ** 17;
    address usdcAddress = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    uint collectedFee;
    IERC20 public farmCoin;
    IERC20 public usdcToken;
    address public collectFeeAddress;
    
    constructor(
        address _farmCoinAddress, // deployed address of farmCoinAddress
        address _collectFeeAddress // address to collect fee amounts
    ) {
        require(_farmCoinAddress != address(0), "Farm Coin address should not be null");
        farmCoin = IERC20(_farmCoinAddress);
        collectFeeAddress = _collectFeeAddress;
        usdcToken = IERC20(usdcAddress);
    }
    
    struct depositInfo {
        uint amount;
        uint method;
        uint depositDate;
    }
    
    mapping(address=>depositInfo) public infoOf;
    
    function deposit(uint _amount, uint _method) external {
        require(infoOf[msg.sender].amount == 0, "Already deposited. Withdraw first");
        uint depositDate = block.timestamp;
        
        infoOf[msg.sender] = depositInfo(_amount, _method, depositDate);
        usdcToken.transferFrom(msg.sender, address(this), _amount);
    }
    
    function getPeriod(uint _method) private pure returns(uint period) {
        if(_method == 0) period = 0;
        if(_method == 1) period = 182 days;
        if(_method == 2) period = 365 days;
    }
    
    function withdraw() external {
        uint fee;
        uint withdrawAmount;
        require(infoOf[msg.sender].amount > 0, "No amount to withdraw. Deposit first");
        (fee, withdrawAmount) = getAmounts(msg.sender);
        collectedFee = collectedFee.add(fee);
        infoOf[msg.sender].amount = 0;
        farmCoin.transfer(msg.sender, withdrawAmount);
    }
    
    function getAmounts(address _userAddress) private view returns(uint feeAmount, uint withdrawAmount) {
        // calculates fee and withdraw amounts according to user information and now time
        uint amount = infoOf[_userAddress].amount.mul(WAD);
        uint method = infoOf[_userAddress].method;
        uint period = getPeriod(method);
        uint depositDate = infoOf[_userAddress].depositDate;
        uint periodLeft = depositDate.add(period) > block.timestamp
            ? depositDate.add(period).sub(block.timestamp)
            : 0;
        uint currentAmount;
        currentAmount = amount.add(
            wmul(
                wmul(amount, method.add(1).mul(PERCENT10)),
                wdiv(periodLeft, 365 days)
            ));
        if(periodLeft > 0) {
            // user withdraws early
            feeAmount = method == 0 ? 0 : wmul(currentAmount, PERCENT10);
            withdrawAmount = currentAmount - feeAmount;
            wmul(wmul(amount, PERCENT10), wdiv(periodLeft, 365 days));
        } else {
            // user withdraws normally
            feeAmount = 0;
            withdrawAmount = currentAmount;
        }
    }
    
    function collectFee() external onlyOwner {
        // only owner can send collected fee amounts to certain target address
        farmCoin.transfer(collectFeeAddress, collectedFee);
        collectedFee = 0;
    }
    
    function changeCollectFeeAddress(address _newAddress) external onlyOwner {
        // only owner can change address to collect fee amounts
        require(_newAddress != address(0), "New CollectFeeAddress should not be null");
        collectFeeAddress = _newAddress;
    }
}