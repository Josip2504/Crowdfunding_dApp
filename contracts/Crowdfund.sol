// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
	string public name;
	string public description;
	uint256 public goal;
	uint256 public deadline;
	address public owner;

	constructor(
		string memory _name,
		string memory _description,
		uint256 _goal,
		uint256 _duration
	) {
		name = _name;
		description = _description;
		goal = _goal;
		deadline = block.timestamp + (_duration * 1 days);
		owner = msg.sender;
	}

	// write function - reqirements are to pay more than 0 and that campaign hasnt ended
	function fund() public payable {
		require(msg.value > 0, "Must fund amount greater than 0.");
		require(block.timestamp < deadline, "Campaign has ended.");
	}

	// write function - requirements are that only owner can withdraw the money and only if goal is reached
	// if all requirements have been reached we can transfer the balance
	function withdraw() public {
		require(msg.sender == owner, "Only the owner can withdraw.");
		require(address(this).balance >= goal, "Goal has not been reached.");

		uint256 balance = address(this).balance;
		require(balance > 0, "No balance to withdraw.");
		payable(owner).transfer(balance);
	}

	// read function
	function getBalance() public view returns (uint256) {
		return address(this).balance;
	}
}