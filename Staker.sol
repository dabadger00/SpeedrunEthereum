// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  mapping ( address => uint256 ) public balances;
  uint256 public constant threshold = 1 ether;

  event Stake(address,uint256);
  uint256 public deadline = block.timestamp + 72 hours;
  bool public openForWithdraw;

  modifier notCompleted() {
    require (exampleExternalContract.completed == false, "Staking has been executed");
    _;
  }

  function stake() public payable {
    require(msg.value > 0, "0 Ether staked");

    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
    console.log("Hello World 2!", 10);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )


  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`

  function execute() notCompleted public {
    if (address(this).balance < threshold) {
      openForWithdraw = true;
    } else {
      openForWithdraw = false;
      if (block.timestamp > deadline) {
        exampleExternalContract.complete{value: address(this).balance}();
      }
    }
    //require(block.timestamp > deadline, "Deadline not reached");
    //require(address(this).balance >= threshold, "Threshold not reached");
   // if ()
    console.log("Hello World", address(this));
   // exampleExternalContract.complete{value: address(this).balance}();
  }

  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
  function withdraw() notCompleted public {  
    require(openForWithdraw == true, "Not open for withdraw, cannot withdraw");
    uint256 withdrawing = balances[msg.sender];
    console.log(openForWithdraw, withdrawing);

    (bool sent, bytes memory data) = msg.sender.call{value: withdrawing}("");
    require(sent, "Failed to withdraw Ether");
    balances[msg.sender] = 0;
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) {
    if (block.timestamp >= deadline) {
      return 0;
    } else {
      return (deadline - block.timestamp);
    }

  }

  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    stake();
  }

}
