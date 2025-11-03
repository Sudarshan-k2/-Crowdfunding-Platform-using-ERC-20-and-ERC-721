// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MyToken.sol";
import "./MyNFT.sol";

contract Crowdfunding {
    struct Campaign {
        string name;
        address creator;
        uint256 target;
        uint256 collected;
        uint256 deadline;
        address tokenAddress;
        bool claimed;
        mapping(address => uint256) contributions;
    }

    uint256 public campaignCount;
    mapping(uint256 => Campaign) public campaigns;

    MyToken public Token;
    MyNFT public NFT;

    constructor(address _tokenAddress, address _nftAddress) {
        Token = MyToken(_tokenAddress);
        NFT = MyNFT(_nftAddress);
    }

    function createCampaign(
        string memory _name,
        uint256 _target,
        uint256 _duration,
        address _tokenAddress
    ) public {
        Campaign storage c = campaigns[campaignCount];

        c.name = _name;
        c.target = _target;
        c.deadline = block.timestamp + _duration;
        c.tokenAddress = _tokenAddress;
        c.creator = msg.sender;
        c.collected = 0;
        c.claimed = false;

        campaignCount++;
    }

    function contribute(uint256 _campaignId, uint256 _amount)
        public
        returns (uint256)
    {
        require(_campaignId < campaignCount, "Invalid campaign ID");

        Campaign storage c = campaigns[_campaignId];

        require(block.timestamp <= c.deadline, "Campaign expired");
        require(
            Token.transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );

        c.collected += _amount;
        c.contributions[msg.sender] += _amount;

        uint256 tokenId = NFT.mint(msg.sender);
        return tokenId;
    }

    function claimFunds(uint256 _campaignId) public {
        require(_campaignId < campaignCount, "Invalid campaign ID");

        Campaign storage c = campaigns[_campaignId];

        require(msg.sender == c.creator, "Only creator can claim");
        require(block.timestamp > c.deadline, "Campaign not ended");
        require(c.collected >= c.target, "Target not met");
        require(!c.claimed, "Already claimed");

        c.claimed = true;
        Token.transfer(c.creator, c.collected);
    }

    function refund(uint256 _campaignId) public {
        require(_campaignId < campaignCount, "Invalid campaign ID");

        Campaign storage c = campaigns[_campaignId];

        require(block.timestamp > c.deadline, "Campaign not ended");
        require(c.collected < c.target, "Target met");
        require(!c.claimed, "Already claimed");

        uint256 contributed = c.contributions[msg.sender];
        require(contributed > 0, "Nothing to refund");

        c.contributions[msg.sender] = 0;
        Token.transfer(msg.sender, contributed);
    }
}
