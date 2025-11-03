// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyNFT {
    string public name;
    string public symbol;
    uint256 private counter;

    address private crowdFundingAddress;

    mapping(uint256 => address) private _ownerOf;
    mapping(address => uint256) private _balanceOf;
    mapping(uint256 => address) public getApproved;
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function ownerOf(uint256 tokenId) public view returns (address owner) {
        owner = _ownerOf[tokenId];
        require(owner != address(0), "Token does not exist");
    }

    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "Zero address");
        return _balanceOf[owner];
    }

    function mint(address to) public onlyCrowdFundingAddress returns (uint256) {
        require(to != address(0), "Mint to zero address");

        uint256 tokenId = ++counter;

        require(_ownerOf[tokenId] == address(0), "Token already minted");

        _ownerOf[tokenId] = to;
        _balanceOf[to] += 1;

        emit Transfer(address(0), to, tokenId);

        return tokenId;
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_ownerOf[tokenId] == from, "Not owner");
        require(to != address(0), "Transfer to zero address");

        bool isApproved = (
            msg.sender == from ||
            getApproved[tokenId] == msg.sender ||
            isApprovedForAll[from][msg.sender]
        );

        require(isApproved, "Not authorized");

        _balanceOf[from] -= 1;
        _balanceOf[to] += 1;
        _ownerOf[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function approve(address to, uint256 tokenId) public {
        address owner = _ownerOf[tokenId];
        require(owner == msg.sender || isApprovedForAll[owner][msg.sender], "Not authorized");

        getApproved[tokenId] = to;

        emit Approval(owner, to, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function setCrowdFundingAddress(address _crowdFundingAddress) public {
        crowdFundingAddress = _crowdFundingAddress;
    }

    modifier onlyCrowdFundingAddress() {
        require(msg.sender == crowdFundingAddress, "Not authorized");
        _;
    }
}
