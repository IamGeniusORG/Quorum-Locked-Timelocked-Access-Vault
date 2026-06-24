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

## 🛠 How to Test & Deploy (Step-by-Step Guide)

You can easily test this entire lifecycle right in your browser using the [Remix IDE](https://remix.ethereum.org/) without needing to install any software! 

### 1. Setup and Compilation
1. **Clone the Repo:** Copy the `QuorumTimelockVault.sol` code from this repository.
2. **Open Remix:** Go to [remix.ethereum.org](https://remix.ethereum.org/) and create a new file named `QuorumTimelockVault.sol` in your workspace. Paste the code inside.
3. **Compile:** Click on the "Solidity Compiler" tab on the far left. Set the compiler version to `0.8.24` (or higher) and click the big blue **Compile** button.

### 2. Deploying the Vault
1. Click the **"Deploy & Run Transactions"** tab on the left.
2. Ensure your Environment is set to **Remix VM**.
3. Right next to the orange "Deploy" button, click the **small down arrow (chevron)** to open the deployment configuration boxes.
4. Fill in the parameters to set up your Vault:
   * **`_keyholders`**: Copy three addresses from your Remix "Account" dropdown at the top of the screen and paste them as an array. *(Example: `["0x5B3...", "0xAb8...", "0x4B2..."]`)*.
   * **`_quorumPercentage`**: Type `66` (This means 2 out of your 3 keyholders must vote to unlock it).
   * **`_secretPayload`**: Type `"MySecretMessage"` (Don't forget the quotes!).
   * **`_votingPeriodSeconds`**: Type `30` (Voters will have 30 seconds to cast their vote).
   * **`_executionDelaySeconds`**: Type `30` (After voting passes, the vault remains locked for 30 seconds).
   * **`_gracePeriodSeconds`**: Type `300` (The community has 5 minutes to extract the secret before the proposal expires).
5. Click the blue **Transact** button. Your contract is now live under "Deployed Contracts" at the bottom left!

### 3. Interacting & Bypassing the Timelock
*Expand your deployed contract by clicking the arrow next to it.*

1. **Submit a Proposal:** Using the *first* account in your Account dropdown, select `submitReleaseProposal` from the function dropdown and click **Transact**. This creates Proposal ID `1`. *(The 30-second voting clock starts now!)*
2. **Cast the Deciding Vote:** Quickly switch your Account dropdown to the *second* address in your list. Select `approveProposal`, type `1` into the input box, and hit **Transact**. You now have 2 out of 3 votes (66% Quorum met!).
3. **Wait for the Timelock:** Since we set the execution delay to 30 seconds, you must wait exactly 30 seconds from the end of the voting period. If you try to unlock it early, the vault will block you with a `TimelockActive` error.
4. **Execute and Unlock:** Once the time has passed, select `executeRelease`, type `1` in the box, and click **Transact**.

🎉 **Boom!** Check your transaction logs at the bottom of the screen. You will see a `PayloadReleased` event outputting your hidden `"MySecretMessage"` string!
