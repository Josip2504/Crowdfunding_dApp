// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Crowdfunding} from "./Crowdfunding.sol";

// contract that deoploys contracts and allows us to keep track of all the contracts so we can desplay them in the app.
// each crowdfunding is gonna be a new contract

contract Factory {
	address public owner;
	bool public paused;

	struct Campaign {
		address campaignAddress;
		address owner;
		string name;
		uint256 creationTime;
	}

	Campaign[] public campaigns;
	mapping(address => Campaign[]) public userCampaigns;

	modifier onlyOwner() {
		require(msg.sender == owner, "Not owner.");
		_;
	}

	modifier notPaused() {
		require(!paused, "Paused.");
		_;
	}

	constructor() {
		owner = msg.sender;
	}

	function createCampaign(
		string memory _name,
		string memory _description,
		uint256 _goal,
		uint256 _duration
	) external notPaused {
		Crowdfunding newCampaign = new Crowdfunding(
			msg.sender,
			_name,
			_description,
			_goal,
			_duration
		);
		address campaignAddress = address(newCampaign);
		
		Campaign memory campaign = Campaign ({
			campaignAddress: campaignAddress,
			owner: msg.sender,
			name: _name,
			creationTime: block.timestamp
		});

		campaigns.push(campaign);
		userCampaigns[msg.sender].push(campaign);
	}

	function getUsersCampaigns(address _user) external view returns (Campaign[] memory) {
		return userCampaigns[_user];
	}

	function getAllCampaigns () external view returns (Campaign[] memory) {
		return campaigns;
	}

	function togglePause () external onlyOwner {
		paused = !paused;
	}
}