# Quorum-Locked Timelocked Access Vault

A highly secure, gas-optimized Ethereum smart contract vault that protects digital secrets and native ETH. 

This project implements enterprise-grade decentralized governance mechanisms to ensure that no single entity can execute a payload release without community consensus and strict cryptographic time delays.

## 🔒 Security Patterns Implemented

1. **Role-Based Access Control (RBAC):** Restricts contract interaction exclusively to a pre-registered array of verified keyholders.
2. **Custom Errors (Solidity ^0.8.4):** Completely replaces string-based `require` statements with Custom Errors (`revert CustomError()`) to massively optimize gas consumption and provide cleaner stack traces.
3. **Sybil Resistance:** Tracks voting states via mappings inside structural objects to completely eliminate double-voting and flash-loan attacks.
4. **Timelock Delays:** Defends against rushed governance attacks by forcing a minimum `votingPeriod` and a strict `executionDelay` before payloads can be extracted.
5. **Grace Periods:** Implements an `expirationTime` constraint, preventing attackers from executing old, forgotten "stale" proposals years after they were approved.
6. **Checks-Effects-Interactions (CEI):** Eliminates reentrancy vectors by updating the `executed` boolean state prior to making any external `.call{value}` Ethereum transfers.
7. **Proposal Cancellation:** Provides the original proposer with an emergency kill-switch (`cancelProposal`) to halt the execution workflow if a flaw is discovered post-submission.

## 🛠 Usage & Deployment

### Prerequisites
- [Remix IDE](https://remix.ethereum.org/) or [Hardhat](https://hardhat.org/) / [Foundry](https://getfoundry.sh/)

### Constructor Arguments
When deploying the contract, you must define its initial state parameters:
- `_keyholders`: `address[]` - List of wallets permitted to vote and propose.
- `_quorumPercentage`: `uint256` - Threshold percentage required to pass a vote (e.g., `66` for 66%).
- `_secretPayload`: `string` - The hidden data string locked within the vault.
- `_votingPeriodSeconds`: `uint256` - How long a proposal accepts votes.
- `_executionDelaySeconds`: `uint256` - Timelock delay between vote-passing and execution.
- `_gracePeriodSeconds`: `uint256` - Time window after the timelock during which execution is valid.

### Core Workflow
1. `submitReleaseProposal()`: Keyholder initializes a request.
2. `approveProposal(uint256 _proposalId)`: Other keyholders submit their affirmative cryptographic assertions.
3. *Wait for `votingPeriod` and `executionDelay` to expire.*
4. `executeRelease(uint256 _proposalId)`: Anyone can execute the passed proposal, emitting the secret via the `PayloadReleased` event and sweeping the vault's ETH to the proposer.

## 📜 License
MIT License.
