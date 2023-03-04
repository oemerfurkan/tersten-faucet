// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

contract TerstenFaucet is Ownable {

    uint256 public totalDonation;
    uint256 donationWithdrawTime = 3 minutes;
    mapping(address => uint256) public donations;
    mapping(address => uint256) public donateTimes;

    event Donated(address donator, uint256 amount);
    event Withdrawn(address withdrawer, uint256 amount, uint256 withdrawTime);

    function donate() public payable {
        require(msg.value > 0, "Eth amount must be bigger tha zero.");
        donateTimes[msg.sender] = block.timestamp;
        totalDonation += msg.value;
        donations[msg.sender] += msg.value;

        emit Donated(msg.sender, msg.value);
    }

    function withdrawDonation(uint256 _withdrawAmount) public {
        uint256 lastWithdrawableTime = donateTimes[msg.sender] + donationWithdrawTime;

        require(donations[msg.sender] >= _withdrawAmount, "You didn't donated that amount.");
        require(block.timestamp < lastWithdrawableTime, "You cannot withdraw your donation anymore.");

        donations[msg.sender] -= _withdrawAmount;
        totalDonation -= _withdrawAmount;

        emit Withdrawn(msg.sender, _withdrawAmount, lastWithdrawableTime - block.timestamp);
    }

    function withdraw(uint256 _withdrawAmount) public onlyOwner {
        require(_withdrawAmount >= address(this).balance, "Contract don't have that much Eth.");
        payable(owner()).transfer(_withdrawAmount);
        totalDonation = 0;
    }
}
