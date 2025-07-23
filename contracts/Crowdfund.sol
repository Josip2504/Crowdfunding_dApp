// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
	string public name;
	string public description;
	uint256 public goal;
	uint256 public deadline;
	address public owner;

	enum CampaignState { Active, Successful, Failed }
	CampaignState public state;

	struct Tier {
		string name;
		uint256 amount;
		uint256 backers;
	}

	Tier[] public tiers;

	modifier onlyOwner() {
		require(msg.sender == owner, "Not the owner.");
		_;	//runs remaining part of funciton if require is ok
	}

	modifier campaignOpen() {
		require(state == CampaignState.Active, "Campaign is not active.");
		_;
	}

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
		state = CampaignState.Active;
	}

	function checkAndUpdateState () internal {
		if (state == CampaignState.Active) {
			if (block.timestamp >= deadline) {
				state = address(this).balance >= goal ? CampaignState.Successful : CampaignState.Failed;
			} else {
				state = address(this).balance >= goal ? CampaignState.Successful : CampaignState.Active;
			}
		}
	}

	// write function - reqirements are to pay more than 0 and that campaign hasnt ended
	function fund(uint256 _tierID) public payable campaignOpen {
		require(_tierID < tiers.length, "Invalid tier.");
		require(msg.value == tiers[_tierID].amount, "Incorect amount");

		tiers[_tierID].backers++;

		checkAndUpdateState();
	}

	function addTier(
		string memory _name,
		uint256 _amount
	) public onlyOwner {
		require(_amount > 0, "Must be greater than 0.");
		tiers.push(Tier(_name, _amount, 0));
	}

	function removeTier(uint256 _id) public onlyOwner {
		require(_id < tiers.length, "Tier does not exist");
		tiers[_id] = tiers[tiers.length - 1];
		tiers.pop();
	}

	// write function - requirements are that only owner can withdraw the money and only if goal is reached
	// if all requirements have been reached we can transfer the balance
	// onlyOwner added after public that will check modifire and if it is ok it will proceede with function
	function withdraw() public onlyOwner {
		checkAndUpdateState();
		require(state == CampaignState.Successful, "Campaign not successful.");

		uint256 balance = address(this).balance;
		require(balance > 0, "No balance to withdraw.");
		payable(owner).transfer(balance);
	}

	// read function
	function getBalance() public view returns (uint256) {
		return address(this).balance;
	}
}