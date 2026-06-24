![Quorum-Locked Timelocked Access Vault Showcase](Tests%20and%20bugs/Showcase.png)

# Quorum-Locked Timelocked Access Vault

Welcome to the **Quorum-Locked Timelocked Access Vault**! 

Have you ever wondered how billion-dollar Web3 companies and Decentralized Autonomous Organizations (DAOs) keep their funds and secrets safe without relying on a single CEO or bank? This project is the answer.

This is a highly secure, enterprise-grade Ethereum smart contract that protects digital assets, native ETH, and secret messages using strict community voting rules.

---

## 🧠 What is this project about? (Explained Simply)

Imagine a high-tech digital safe. 
Usually, a safe has one key, and whoever holds that key can open it. But what if that person loses the key, or turns out to be untrustworthy?

This vault solves that problem by requiring a **Quorum** (a majority vote) and a **Timelock** (a mandatory waiting period):
1. **The Board of Directors (Keyholders):** You choose a list of trusted wallets when you build the vault.
2. **The Quorum (The Vote):** To open the safe, one person must propose to open it, and the others must vote "Yes". The safe will *only* prepare to open if a certain percentage (like 66%) agrees.
3. **The Timelock (The Waiting Period):** Even after everyone agrees, the safe refuses to open immediately. It starts a countdown clock. This ensures that if the vote was somehow rigged, the community has time to sound the alarm and use the emergency **Cancel** button before the safe unlocks!

---

## 🌍 Real-World Practical Use Cases

Why do we need this in the real world?

* **Decentralized Treasuries (DAOs):** Securing millions of dollars in a community treasury. No single hacker can steal the money because they would need to compromise the majority of the board members' wallets at the exact same time.
* **Corporate Multi-Signature Wallets:** A Web3 company using this vault for payroll. The HR manager submits the payroll, the founders vote to approve it, and the funds unlock safely.
* **Protocol Upgrades:** When major DeFi apps (like Uniswap) upgrade their code, they use this exact mechanism to give users a 48-hour warning before the code changes.
* **Digital Inheritance:** A highly valuable asset (like a rare NFT) is locked away. If the owner passes away, trusted family members vote to unlock the inheritance safely.

---

## 🔒 Advanced Security Features

Under the hood, this contract was written with advanced Solidity optimizations to make it professional, cheap to run, and impenetrable:

1. **Custom Errors (Solidity ^0.8.4):** We completely removed old-school `require` strings and replaced them with Custom Errors (`revert CustomError()`). This massively optimizes gas consumption for users interacting with the vault.
2. **Checks-Effects-Interactions (CEI):** Eliminates devastating reentrancy attacks by explicitly updating the `executed` boolean state *prior* to making any external Ethereum transfers.
3. **Sybil Resistance:** Tracks voting states via mappings inside structural objects to completely eliminate double-voting and flash-loan attacks.
4. **Grace Periods:** Implements an `expirationTime` constraint. This prevents attackers from executing old, forgotten "stale" proposals years after they were approved.
5. **Emergency Kill-Switch:** Provides the original proposer with a `cancelProposal` function to halt the execution workflow if a flaw is discovered post-submission.

---

## 🛠 How to Test & Deploy

You can test this right now in your browser using the [Remix IDE](https://remix.ethereum.org/).

1. Paste `QuorumTimelockVault.sol` into Remix.
2. Compile using Solidity `0.8.24` or higher.
3. **Deploy** by passing in an array of trusted wallet addresses, your required quorum percentage (e.g., `66`), your secret message, and the timelock delays in seconds.
4. **Interact:** Use `submitReleaseProposal` to start a vote, use `approveProposal` from a different wallet to cast a vote, wait for the timelock to expire, and finally call `executeRelease` to unlock the vault!
