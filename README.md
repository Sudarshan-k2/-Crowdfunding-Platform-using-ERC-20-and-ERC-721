# Crowdfunding Platform (ERC20 Funding + NFT Rewards)

A decentralized crowdfunding application built using **Solidity**, where users 
contribute using a custom **ERC20 token (MyToken)** and receive an **ERC721 NFT 
(MyNFT)** as proof of contribution.

This project demonstrates multi-contract architecture, reward mechanisms, and 
secure on-chain contribution tracking.

---

## ✅ Key Features

### 🔹 1. Create Campaigns (On-Chain)
Campaigns include:
- name  
- creator  
- target amount  
- deadline  
- ERC20 token address  
- total collected  
- refund/claim status  

Each campaign is stored on-chain in the `campaigns` mapping.

---

### 🔹 2. Contribute Using ERC20 Tokens
- Users contribute with `transferFrom`
- Each contributor's amount is tracked internally
- Contribution triggers minting of a **reward NFT**:
- uint tokenId = NFT.mint(msg.sender)
- 
This gives users a verifiable on-chain badge of participation.

---

### 🔹 3. Creator Withdraws Funds (If Goal Met)
Creator can withdraw funds only if:
1. Campaign deadline passed  
2. Total collected ≥ target  
3. Funds not already claimed  

Funds are transferred automatically through the ERC20 token.

---

### 🔹 4. Refund System (If Goal Not Met)
If:
- deadline passed
- collected < target
- not claimed

Contributors can refund:
Token.transfer(msg.sender, contributions[msg.sender])


Trustless refunds ensure complete fairness.

---

## ✅ Smart Contract Architecture

### **Contracts**
- `MyToken.sol` → Custom ERC20 token  
- `MyNFT.sol` → Custom ERC721 NFT  
- `Crowdfunding.sol` → Core crowdfunding logic  

### **Structs and Mappings**
```solidity
struct Campaign {
    string name;
    address creator;
    uint target;
    uint collected;
    uint deadline;
    address tokenAddress;
    bool claimed;
    mapping(address => uint) contributions;
}

