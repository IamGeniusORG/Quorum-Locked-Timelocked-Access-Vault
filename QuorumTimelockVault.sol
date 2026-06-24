// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title Quorum-Locked Timelocked Access Vault
 * @author YourName / IamGenius
 * @dev Secure vault that locks a string secret and/or ETH. 
 * Requires a minimum quorum of registered keyholders to approve a release proposal.
 * Incorporates a timelock mechanism (voting period + execution delay) and a grace period for execution.
 * Upgraded with Custom Errors for extreme gas efficiency and cancellation workflows.
 */
contract QuorumTimelockVault {
    // --- Custom Errors (Gas Optimization & Professional Standard) ---
    error NotKeyholder(address caller);
    error InvalidConfiguration();
    error ProposalDoesNotExist(uint256 proposalId);
    error VotingEnded(uint256 proposalId, uint256 currentTime, uint256 endTime);
    error AlreadyVoted(uint256 proposalId, address voter);
    error ProposalAlreadyExecuted(uint256 proposalId);
    error ProposalCanceled(uint256 proposalId);
    error TimelockActive(uint256 proposalId, uint256 currentTime, uint256 executionTime);
    error QuorumNotMet(uint256 proposalId, uint256 currentQuorum, uint256 requiredQuorum);
    error ProposalExpired(uint256 proposalId, uint256 currentTime, uint256 expirationTime);
    error TransferFailed();
    error OnlyProposerCanCancel();

    // --- State Variables ---
    string private secretPayload;
    uint256 public totalKeyholders;
    uint256 public quorumPercentage;
    
    uint256 public immutable votingPeriod;
    uint256 public immutable executionDelay;
    
    // Security Upgrade: Grace Period to prevent stale proposals from being executed years later
    uint256 public immutable gracePeriod; 

    // --- Mappings ---
    mapping(address => bool) public isKeyholder;
    
    // --- Structs ---
    struct ReleaseProposal {
        uint256 id;
        address proposer;
        uint256 startTime;
        uint256 endTime;
        uint256 executionTime;
        uint256 expirationTime; // End of the grace period
        uint256 approvalCount;
        bool executed;
        bool canceled; // Security Upgrade: Allow canceling compromised proposals
        bool exists;
        mapping(address => bool) hasVoted;
    }
    
    mapping(uint256 => ReleaseProposal) public proposals;
    uint256 public proposalCount;
    
    // --- Events ---
    event KeyholderAdded(address indexed keyholder);
    event ProposalCreated(uint256 indexed proposalId, address indexed proposer, uint256 endTime);
    event VoteCast(uint256 indexed proposalId, address indexed voter);
    event ProposalCanceledEvent(uint256 indexed proposalId);
    event PayloadReleased(uint256 indexed proposalId, string payload);
    event VaultFunded(address indexed sender, uint256 amount);
    event FundsReleased(uint256 indexed proposalId, address indexed recipient, uint256 amount);

    // --- Modifiers ---
    modifier onlyKeyholder() {
        if (!isKeyholder[msg.sender]) revert NotKeyholder(msg.sender);
        _;
    }

    // --- Constructor ---
    constructor(
        address[] memory _keyholders, 
        uint256 _quorumPercentage, 
        string memory _secretPayload,
        uint256 _votingPeriodSeconds,
        uint256 _executionDelaySeconds,
        uint256 _gracePeriodSeconds
    ) payable {
        if (_keyholders.length == 0 || _quorumPercentage == 0 || _quorumPercentage > 100) revert InvalidConfiguration();
        
        for (uint256 i = 0; i < _keyholders.length; i++) {
            address keyholder = _keyholders[i];
            if (keyholder == address(0) || isKeyholder[keyholder]) revert InvalidConfiguration();
            
            isKeyholder[keyholder] = true;
            emit KeyholderAdded(keyholder);
        }
        
        totalKeyholders = _keyholders.length;
        quorumPercentage = _quorumPercentage;
        secretPayload = _secretPayload;
        votingPeriod = _votingPeriodSeconds;
        executionDelay = _executionDelaySeconds;
        gracePeriod = _gracePeriodSeconds;
    }

    // --- Core Functions ---
    function submitReleaseProposal() external onlyKeyholder returns (uint256) {
        proposalCount++;
        uint256 newProposalId = proposalCount;
        
        ReleaseProposal storage proposal = proposals[newProposalId];
        proposal.id = newProposalId;
        proposal.proposer = msg.sender;
        proposal.startTime = block.timestamp;
        
        proposal.endTime = block.timestamp + votingPeriod;
        proposal.executionTime = proposal.endTime + executionDelay;
        proposal.expirationTime = proposal.executionTime + gracePeriod;
        proposal.exists = true;
        
        emit ProposalCreated(newProposalId, msg.sender, proposal.endTime);
        
        // Auto-vote for the proposer
        _castVote(newProposalId, msg.sender);
        
        return newProposalId;
    }

    function approveProposal(uint256 _proposalId) external onlyKeyholder {
        _castVote(_proposalId, msg.sender);
    }

    /**
     * @dev Security Feature: Allows the original proposer to cancel a proposal before execution
     * in case of an emergency or discovered flaw.
     */
    function cancelProposal(uint256 _proposalId) external onlyKeyholder {
        ReleaseProposal storage proposal = proposals[_proposalId];
        if (!proposal.exists) revert ProposalDoesNotExist(_proposalId);
        if (msg.sender != proposal.proposer) revert OnlyProposerCanCancel();
        if (proposal.executed) revert ProposalAlreadyExecuted(_proposalId);
        if (proposal.canceled) revert ProposalCanceled(_proposalId);

        proposal.canceled = true;
        emit ProposalCanceledEvent(_proposalId);
    }

    function _castVote(uint256 _proposalId, address _voter) internal {
        ReleaseProposal storage proposal = proposals[_proposalId];
        
        if (!proposal.exists) revert ProposalDoesNotExist(_proposalId);
        if (proposal.canceled) revert ProposalCanceled(_proposalId);
        if (block.timestamp >= proposal.endTime) revert VotingEnded(_proposalId, block.timestamp, proposal.endTime);
        if (proposal.executed) revert ProposalAlreadyExecuted(_proposalId);
        if (proposal.hasVoted[_voter]) revert AlreadyVoted(_proposalId, _voter);

        proposal.hasVoted[_voter] = true;
        proposal.approvalCount++;

        emit VoteCast(_proposalId, _voter);
    }

    function executeRelease(uint256 _proposalId) external onlyKeyholder returns (string memory) {
        ReleaseProposal storage proposal = proposals[_proposalId];
        
        // 1. Validation Checks (Checks)
        if (!proposal.exists) revert ProposalDoesNotExist(_proposalId);
        if (proposal.canceled) revert ProposalCanceled(_proposalId);
        if (proposal.executed) revert ProposalAlreadyExecuted(_proposalId);
        
        // Time bounds validation
        if (block.timestamp < proposal.executionTime) revert TimelockActive(_proposalId, block.timestamp, proposal.executionTime);
        if (block.timestamp > proposal.expirationTime) revert ProposalExpired(_proposalId, block.timestamp, proposal.expirationTime);
        
        // Quorum Verification
        uint256 currentQuorumPercent = (proposal.approvalCount * 100) / totalKeyholders;
        if (currentQuorumPercent < quorumPercentage) revert QuorumNotMet(_proposalId, currentQuorumPercent, quorumPercentage);

        // 2. State Updates (Effects - Reentrancy Guard)
        proposal.executed = true;

        // 3. Interactions
        emit PayloadReleased(_proposalId, secretPayload);
        
        uint256 balance = address(this).balance;
        if (balance > 0) {
            (bool success, ) = proposal.proposer.call{value: balance}("");
            if (!success) revert TransferFailed();
            emit FundsReleased(_proposalId, proposal.proposer, balance);
        }
        
        return secretPayload;
    }
    
    receive() external payable {
        emit VaultFunded(msg.sender, msg.value);
    }
    
    function getProposalDetails(uint256 _proposalId) external view returns (
        address proposer,
        uint256 startTime,
        uint256 endTime,
        uint256 executionTime,
        uint256 expirationTime,
        uint256 approvalCount,
        bool executed,
        bool canceled,
        bool exists
    ) {
        ReleaseProposal storage p = proposals[_proposalId];
        return (p.proposer, p.startTime, p.endTime, p.executionTime, p.expirationTime, p.approvalCount, p.executed, p.canceled, p.exists);
    }
}
